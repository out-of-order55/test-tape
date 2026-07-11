package chipyard

import org.chipsalliance.cde.config.Config

/** Default integer Gemmini attached to one Rocket core. */
class GemminiRocketConfig extends Config(
  new gemmini.DefaultGemminiConfig ++
  new freechips.rocketchip.rocket.WithNHugeCores(1) ++
  new chipyard.config.WithSystemBusWidth(128) ++
  new chipyard.config.AbstractConfig)
