document.addEventListener("click", (event) => {
  if (!(event.target instanceof Element)) return;
  const button = event.target.closest("[data-json-action]");
  if (!(button instanceof HTMLButtonElement)) return;
  const viewer = button.closest(".json-viewer");
  if (!viewer) return;
  const expanded = button.dataset.jsonAction === "expand";
  viewer.querySelectorAll("details.json-node").forEach((node) => {
    node.open = expanded;
  });
});
