// おしゃれなフラッシュメッセージ表示
addEventListener('load', ()=> {
  const flashWindow = document.getElementsByClassName("flash-window")[0];
  
  // 要素が存在するか確認する
  if (flashWindow) {
    flashWindowToggle();
    setTimeout(flashWindowToggle, 3000);

    const closeButton = document.getElementsByClassName("flash-window--delete")[0];
    
    if (closeButton) {
      closeButton.addEventListener('click', flashWindowToggle);
    }
  }

  function flashWindowToggle() {
    flashWindow.classList.toggle("hidden");
  }
});