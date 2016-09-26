MBus
====

MBus is the next-generation interconnect that enables the millimeter-scale
computing class.

MBus is a chip-to-chip bus designed for ultra-constrained systems. MBus is a
multi-master bus supporting an arbitrary number of nodes, priority arbitration,
efficient acknowledgements, and extensible addressing, with only four wires and
consuming only 3.5 pJ/bit/chip.

MBus is _power-aware_, enabling the design of _power-oblivious_ systems.
Individual chips can fully power off and MBus will automatically take care of
all the tricky details.

For more information visit [mbus.io](http://mbus.io).


Repository Layout
-----------------

This repository contains a reference MBus implementation and is the
implementation used by the Michigan Micro Mote project at the University of
Michigan. The MBus Verilog is considered stable and has been tested in dozens
of fabricated chips.

 * `releases`: Packaged, formal releases of MBus. Use the latest release if you
   wish to include MBus in your own projects. The `mbus_example` directory is
   the template for creating new releases.
 * `mbus`: The development directory of MBus.
 * `layer_controller_*`: A higher-level interface that wraps the MBus frontend.
   The layer controller implements the MPQ protocol described in the
   [MBus Specification](http://mbus.io/spec.html) and provides a register/memory
   interface to the rest of the chip.
   - The layer controller originally had separate implementations for simpler
     peripherals and complex chips (the CPU). As of v3, these are now
     consolidated into a unified design.


------------


Copyright 2015 Regents of the University of Michigan

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


MBus Name and Logo
------------------

Use of the MBus name and logo are subject to the MBus Research End User License Agreement.

The agreement is available at http://mbus.io/static/MBus_EULA_v1.0.pdf


