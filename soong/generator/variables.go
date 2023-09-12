package generator

import (
	"fmt"

	"android/soong/android"
)

func neotericExpandVariables(ctx android.ModuleContext, in string) string {
	neotericVars := ctx.Config().VendorConfig("neotericVarsPlugin")

	out, err := android.Expand(in, func(name string) (string, error) {
		if neotericVars.IsSet(name) {
			return neotericVars.String(name), nil
		}
		// This variable is not for us, restore what the original
		// variable string will have looked like for an Expand
		// that comes later.
		return fmt.Sprintf("$(%s)", name), nil
	})

	if err != nil {
		ctx.PropertyErrorf("%s: %s", in, err.Error())
		return ""
	}

	return out
}
