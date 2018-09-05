package main

import (
	"fmt"
	"io"
	"os"
	"runtime"
	"time"

	"github.com/kamilsk/guard/cmd"
	"github.com/spf13/cobra"

	_ "github.com/go-chi/chi"
	_ "github.com/lib/pq"
	_ "github.com/mailru/easyjson"
	_ "github.com/pkg/errors"
	_ "github.com/stretchr/testify"
)

const (
	success = 0
	failed  = 1
)

var (
	commit  = "none"
	date    = time.Now().Format(time.UnixDate)
	version = "dev"
)

func main() { application{Commander: cmd.RootCmd, Output: os.Stderr, Shutdown: os.Exit}.run() }

type application struct {
	Commander interface {
		AddCommand(...*cobra.Command)
		Execute() error
	}
	Output   io.Writer
	Shutdown func(code int)
}

func (app application) run() {
	defer func() {
		if r := recover(); r != nil {
			app.Shutdown(failed)
		}
	}()
	app.Commander.AddCommand(&cobra.Command{
		Use:   "version",
		Short: "Show application version",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Fprintf(app.Output,
				"Version %s (commit: %s, build date: %s, go version: %s, compiler: %s, platform: %s)\n",
				version, commit, date, runtime.Version(), runtime.Compiler, runtime.GOOS+"/"+runtime.GOARCH)
		},
		Version: version,
	})
	if err := app.Commander.Execute(); err != nil {
		app.Shutdown(failed)
	}
	app.Shutdown(success)
}