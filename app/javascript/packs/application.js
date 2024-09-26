// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
// Turbolinks.start()
ActiveStorage.start()

import "jquery";
import "popper.js";
import "bootstrap";

// 会員・管理者共通関係
import "../stylesheets/application"; 
import "../stylesheets/shared"
import "../stylesheets/top"
// 会員関係
import "../stylesheets/about"
import "../stylesheets/my_page"
import "../stylesheets/check"
// 管理者関係
import "../stylesheets/admin_top"

// おしゃれなフラッシュメッセージ表示
//= stub flash_window
//= require_tree .