/*
Copyright © 2021 NAME HERE <EMAIL ADDRESS>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package cmd

import (
	"fmt"
	"os"
	"strings"

	"github.com/spf13/cobra"

	"github.com/spf13/viper"
)

const (
	// commandName describe the plugin command name
	commandName = "pod-interface"
)

var cfgFile string

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   fmt.Sprintf("%s command", commandName),
	Short: fmt.Sprintf("kubectl %s is a pod utility interactive plugin for kubectl", commandName),
	Args:  cobra.MinimumNArgs(1),
	Long: strings.ReplaceAll(`
kubectl {COMMAND_NAME} is a fun, quick, 1-command, pod utility interactive kubectl plugin which wraps kubectl commands, to help you easily interact with your running kubernetes pods

Manual:

  # 1. pex: quick, 1-command, interactive, Kubernetes pod exec utility
  # get a shell to a running Container.
  $ kubectl {COMMAND_NAME} pex

  # 2. pof: quick, 1-command, interactive, Kubernetes pod port-forward utility
  # forward local port to a running pod.
  $ kubectl {COMMAND_NAME} pof

  # 3. pdl : quick, 1-command, interactive, Kubernetes pod deletion utility
  # delete running pod.
  $ kubectl {COMMAND_NAME} pdel

  # 4. plg : quick, 1-command, interactive, Kubernetes pod logs utility
  # print the logs for a container in a pod.
  $ kubectl {COMMAND_NAME} plog

  # 5. pcp : quick, 1-command, interactive, Kubernetes pod copy files utility
  # securely copy files from a container in a pod to your local machine.
  $ kubectl {COMMAND_NAME} pcp

  # 6. pcpl : quick, 1-command, interactive, Kubernetes pod copy files utility
  # securely copy files from your local machine to a container in a pod.
  $ kubectl {COMMAND_NAME} pcpl

  `, "{COMMAND_NAME}", commandName),

}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	cobra.CheckErr(rootCmd.Execute())
}

func init() {
	cobra.OnInitialize(initConfig)

	// Here you will define your flags and configuration settings.
	// Cobra supports persistent flags, which, if defined here,
	// will be global for your application.

	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.kubectl-pod-interface.yaml)")

	// Cobra also supports local flags, which will only run
	// when this action is called directly.
	rootCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}

// initConfig reads in config file and ENV variables if set.
func initConfig() {
	if cfgFile != "" {
		// Use config file from the flag.
		viper.SetConfigFile(cfgFile)
	} else {
		// Find home directory.
		home, err := os.UserHomeDir()
		cobra.CheckErr(err)

		// Search config in home directory with name ".kubectl-pod-interface" (without extension).
		viper.AddConfigPath(home)
		viper.SetConfigType("yaml")
		viper.SetConfigName(".kubectl-pod-interface")
	}

	viper.AutomaticEnv() // read in environment variables that match

	// If a config file is found, read it in.
	if err := viper.ReadInConfig(); err == nil {
		fmt.Fprintln(os.Stderr, "Using config file:", viper.ConfigFileUsed())
	}
}
