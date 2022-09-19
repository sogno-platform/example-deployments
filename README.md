# SOGNO Example Deployments

This repository contains deployment instructions and configuration files for different example deployments of the SOGNO platform.
More detailed descriptions and high-level architecture descriptions are available on our official [documentation](https://sogno-platform.github.io/docs/) pages.

## Running examples using vagrant and virtualbox

- [PMU Data Visualization](pmu-data-visualization)
- [Pyvolt DPsim Demo](pyvolt-dpsim-demo)
- [Simulation Demo](simulation-demo)

Each example runs in a vm (8gb ram, 2cpu) provisioned by a vagrant script.

- [PMU Data Visualization](pmu-data-visualization) execute:  `cd vagrant && vagrant up pmudatavisualization`
- [Pyvolt DPsim Demo](pyvolt-dpsim-demo) execute:  `cd vagrant && vagrant up pyvoltdpsim`
- [Simulation Demo](simulation-demo) execute: `cd vagrant && vagrant up simulation`

In case VMware is preferred please run appending:

`cd vagrant && vagrant up <the-demo-you-want> --provider vmware_desktop`
