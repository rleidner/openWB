#!/usr/bin/env python3
from typing import Dict, Tuple, Union
import logging
from pymodbus.constants import Endian

from dataclass_utils import dataclass_from_dict
from modules.common import modbus
from modules.common import simcount
from modules.common.component_state import BatState
from modules.common.component_type import ComponentDescriptor
from modules.common.modbus import ModbusDataType
from modules.common.fault_state import ComponentInfo
from modules.common.store import get_bat_value_store
from modules.solaredge.config import SolaredgeBatSetup

log = logging.getLogger(__name__)

FLOAT32_UNSUPPORTED = -0xffffff00000000000000000000000000


class SolaredgeBat:
    def __init__(self,
                 device_id: int,
                 component_config: Union[Dict, SolaredgeBatSetup],
                 tcp_client: modbus.ModbusTcpClient_) -> None:
        self.__device_id = device_id
        self.component_config = dataclass_from_dict(SolaredgeBatSetup, component_config)
        self.__tcp_client = tcp_client
        self.__sim_count = simcount.SimCountFactory().get_sim_counter()()
        self.simulation = {}
        self.__store = get_bat_value_store(self.component_config.id)
        self.component_info = ComponentInfo.from_component_config(self.component_config)

    def update(self, state: BatState) -> None:
        self.__store.set(state)

    def read_state(self):
        power, soc = self.get_values()
        imported, exported = self.get_imported_exported(power)
        return BatState(
            power=power,
            soc=soc,
            imported=imported,
            exported=exported
        )

    def get_values(self) -> Tuple[float, float]:
        unit = self.component_config.configuration.modbus_id
        soc = self.__tcp_client.read_holding_registers(
            62852, ModbusDataType.FLOAT_32, wordorder=Endian.Little, unit=unit)
        power = self.__tcp_client.read_holding_registers(
            62836, ModbusDataType.FLOAT_32, wordorder=Endian.Little, unit=unit)
        if power == FLOAT32_UNSUPPORTED:
            power = 0
        return power, soc

    def get_imported_exported(self, power: float) -> Tuple[float, float]:
        topic_str = "openWB/set/system/device/" + str(
            self.__device_id)+"/component/"+str(self.component_config.id)+"/"
        return self.__sim_count.sim_count(
            power, topic=topic_str, data=self.simulation, prefix="speicher"
        )


component_descriptor = ComponentDescriptor(configuration_factory=SolaredgeBatSetup)
