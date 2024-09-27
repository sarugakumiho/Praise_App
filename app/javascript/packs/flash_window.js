// おしゃれなフラッシュメッセージ表示
document.addEventListener('DOMContentLoaded', () => {
  const flashWindow = document.getElementsByClassName("flash-window")[0];

  // 要素が存在するか確認する
  if (flashWindow) {
    // 初期状態でフラッシュメッセージを表示
    flashWindow.classList.add("slide-down");

    // 3秒後にフラッシュメッセージを隠す
    setTimeout(() => {
      flashWindow.classList.remove("slide-down");
      flashWindow.classList.add("hidden"); // hidden クラスを追加して非表示にする
    }, 3000);

    // 閉じるボタンを探してクリックイベントを追加
    const closeButton = document.getElementsByClassName("flash-window--delete")[0];
    if (closeButton) {
      closeButton.addEventListener('click', () => {
        flashWindow.classList.remove("slide-down");
        flashWindow.classList.add("hidden"); // 閉じるボタンが押されたら非表示にする
      });
    }
  }
});