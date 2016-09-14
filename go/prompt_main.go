package prompt

import "log"
import "github.com/sethpollen/sbp_linux_config/go/git"
import "github.com/sethpollen/sbp_linux_config/go/hg"

func main() {
	err := DoMain([]Module{git.Module(), hg.Module()}, nil)
	if err != nil {
		log.Fatalln(err)
	}
}
