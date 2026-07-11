package chipyard

import org.chipsalliance.cde.config.Config

/** A compact BOOMv3 system intended for RTL simulation and software bring-up. */
class SmallBoomV3Config extends Config(
  new boom.v3.common.WithNSmallBooms(1) ++
  new chipyard.config.AbstractConfig)
