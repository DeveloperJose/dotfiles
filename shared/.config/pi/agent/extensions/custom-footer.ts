/**
 * Custom Footer Extension - auto-enabled
 *
 * Shows: ↑tokens | x/y tokens ████░░░░ pct% | model (branch) | extension statuses
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const FILL = "█";
const EMPTY = "░";

function formatTokens(n: number): string {
	if (n < 1000) return `${n}`;
	if (n < 10000) return `${(n / 1000).toFixed(1)}k`;
	return `${Math.round(n / 1000)}k`;
}

export default function (pi: ExtensionAPI) {
	pi.on("before_agent_start", async (_event, ctx) => {
		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsub = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose: unsub,
				invalidate() {},
				render(width: number): string[] {
					const branch = footerData.getGitBranch();
					const statuses = footerData.getExtensionStatuses?.() || [];

					const input = ctx.sessionManager.getBranch().reduce((sum, e) => {
						if (e.type === "message" && e.message.role === "assistant") {
							const m = e.message as AssistantMessage;
							return sum + m.usage.input + m.usage.output;
						}
						return sum;
					}, 0);

					const usage = ctx.getContextUsage();
					let contextStr = "";
					if (usage && ctx.model?.contextWindow) {
						const pct = Math.round((usage.tokens / ctx.model.contextWindow) * 100);
						const barLen = Math.min(20, Math.max(3, Math.round(pct / 5)));
						const filled = FILL.repeat(barLen);
						const empty = EMPTY.repeat(20 - barLen);
						contextStr = ` ${formatTokens(usage.tokens)}/${formatTokens(ctx.model.contextWindow)} ${filled}${empty} ${pct}%`;
					}

					const branchStr = branch ? ` (${branch})` : "";
					const modelStr = ctx.model?.id?.split("/").pop() || "no-model";

					const left = theme.fg("accent", `↑${formatTokens(input)}`);
					const mid = contextStr ? theme.fg("dim", contextStr) : "";
					const right = theme.fg("dim", `${modelStr}${branchStr}`);

					const statusesStr = (Array.isArray(statuses) ? statuses : []).filter((s: string) => s && !s.startsWith("defaults:")).join(" | ");
					const statusPart = statusesStr ? ` | ${theme.fg("dim", statusesStr)}` : "";

					const totalLeft = visibleWidth(left) + visibleWidth(mid);
					const pad = " ".repeat(Math.max(1, width - totalLeft - visibleWidth(right) - visibleWidth(statusPart)));

					return [truncateToWidth(left + mid + pad + right + statusPart, width)];
				},
			};
		});
	});
}