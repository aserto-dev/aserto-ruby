//go:build mage
// +build mage

package main

import (
	"fmt"
	"os"

	"github.com/aserto-dev/mage-loot/common"
	"github.com/aserto-dev/mage-loot/deps"
	"github.com/magefile/mage/sh"
)

const (
	gemName = "aserto"
)

// install required dependencies.
func Deps() {
	deps.GetAllDeps()
}

func Bump(next string) error {
	nextVersion, err := common.NextVersion(next)
	if err != nil {
		return err
	}
	fmt.Println("Bumping version to", nextVersion)

	fi, err := os.OpenFile("VERSION", os.O_RDWR|os.O_CREATE, 0755)
	if err != nil {
		return err
	}
	defer fi.Close()

	_, err = fi.WriteString(nextVersion)
	return err
}

// builds the gem
func Build() error {
	err := sh.RunV("mkdir", "-p", "build")
	if err != nil {
		return err
	}

	version, err := sh.Output("cat", "VERSION")
	if err != nil {
		return err
	}

	return sh.RunV("gem", "build", "--output", fmt.Sprintf("./build/%s-%s.gem", gemName, version))
}

func Push() error {
	version, err := sh.Output("cat", "VERSION")
	if err != nil {
		return err
	}

	return sh.RunV("gem", "push", fmt.Sprintf("./build/%s-%s.gem", gemName, version))
}

func Release() error {
	err := Build()
	if err != nil {
		return err
	}
	return Push()
}
