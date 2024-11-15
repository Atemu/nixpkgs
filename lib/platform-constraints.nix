{ lib }:

# This defines an algebra to express platform constraints using AND, OR and NOT
# which behave like boolean operators but for platform properties.
#
# Examples:
#
# with lib.meta.platform.constraints;
# OR [
#   isLinux
#   isDarwin
# ]
#
# with lib.meta.platform.constraints;
# AND [
#   (OR [
#     isLinux
#     isDarwin
#   ])
#   (OR [
#     isx86
#     isAarch
#   ])
#   (NOT isMusl)
# ]

let
  inherit (lib.meta) platformMatch;
  inherit (lib) head;

  operations = {
    OR = lib.any lib.id;
    AND = lib.all lib.id;
    NOT = x: !(head x);
    NONE = _: false;
    ANY = _: true;
  };

in

rec {
  constraints =
    {
      OR = constraints: {
        __operation = "OR";
        value = constraints;
      };

      AND = constraints: {
        __operation = "AND";
        value = constraints;
      };

      NOT = constraint: {
        __operation = "NOT";
        value = [ constraint ]; # Also make this a list for simplicity
      };

      NONE = {
        __operation = "NONE";
        value = [ ];
      };

      ANY = {
        __operation = "ANY";
        value = [ ];
      };
    }
    # Put patterns in this set for convenient use
    // lib.systems.inspect.patterns
    # Platform patterns too. We can just do this because platforms (i.e. `hostPlatform`) have all of these
    # mashed together too.
    // lib.systems.inspect.platformPatterns;

  # Evaluates a platform constraints expression down into a boolean value
  # similar to how lib.meta.platformMatch performs checks a single constraint.
  # Because this uses lib.meta.platformMatch internally it supports the same set
  # of platform constraints.
  evalConstraints =
    platform: constraint:
    if constraint ? __operation then
      operations.${constraint.__operation} (map (evalConstraints platform) constraint.value)
    else
      platformMatch platform constraint;
}
