import type { Plugin } from "@opencode-ai/plugin"

export const ContextPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  return {
    // Type-safe hook implementations
    config: async (input) => {
      console.log("Config ContextPlugin")
      input.command ??= {}
      input.command.context = {
        description: "Manage context for the current session",
        template: "",
      }
    },
    "command.execute.before": async (input, output) => {
      console.log("Context command trigger")
      // console.log(JSON.stringify(input, null, 2))
      // console.log(JSON.stringify(output, null, 2))
      // console.log(JSON.stringify(project, null, 2))
      // console.log(JSON.stringify(client, null, 2))
      // console.log(JSON.stringify($, null, 2))
      // console.log(JSON.stringify(directory, null, 2))
      // console.log(JSON.stringify(worktree, null, 2))
      if (input.command === "context") {
        return
      }
    },
    event: async ( { event }) => {
      if (event.type === "message.exchange.after") {
        const { sessionID, messageID, usage, request, response, finishReason } = event.properties
        console.log(usage)
        console.log(request)
        console.log(response)
        console.log(finishReason)
      }
    },
  }
}
