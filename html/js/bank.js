// TODO: removing jQuery

/*
    Utils
*/

let CONFIG;

fetch(`https://${GetParentResourceName()}/getConfig`, {
  method: "GET",
})
  .then((response) => response.json())
  .then((response) => {
    CONFIG = JSON.parse(response);
  });

const COLOURS_TYPES = {
  0: {
    color: "#FF727A",
    indicator: "-",
  },
  1: {
    color: "#66CE7D",
    indicator: "+",
  },
  2: {
    color: "#66CE7D",
    indicator: "+",
  },
};

const formatDate = (date) => {
  let d = new Date(date),
    month = "" + (d.getMonth() + 1),
    day = "" + d.getDate(),
    year = d.getFullYear();

  if (month.length < 2) month = "0" + month;
  if (day.length < 2) day = "0" + day;

  return [day, month, year].join("-");
};

const formatTime = (date) => {
  return (
    ("0" + date.getHours()).slice(-2) +
    "h" +
    ("0" + date.getMinutes()).slice(-2)
  );
};

const conform = (element) => {
  return element.toString().match(/^-?\d+$/);
};

// this functions must be in one, combine with all of them
const calculateSpentMonth = (transfers) => {
  let result = 0;

  transfers.forEach((transfer) => {
    if (transfer.action === 0 || transfer.action === 2) {
      const days = Math.abs(
        Math.ceil(
          (new Date(transfer.date).getTime() - today.getTime()) /
            (1000 * 3600 * 24)
        )
      );

      if (days <= 30) {
        result += transfer.amount;
      }
    }
  });

  return result;
};

const calculateSpentWeek = (transfers) => {
  let result = 0;

  transfers.forEach((transfer) => {
    if (transfer.action === 0 || transfer.action === 2) {
      const days = Math.abs(
        Math.ceil(
          (new Date(transfer.date).getTime() - today.getTime()) /
            (1000 * 3600 * 24)
        )
      );

      if (days <= 7) {
        result += transfer.amount;
      }
    }
  });

  return result;
};

const calculateTodayEarning = (transfers) => {
  let result = 0;

  transfers.forEach((transfer) => {
    if (transfer.action === 1) {
      if (formatDate(transfer.date) === formatDate(Date.now())) {
        result += transfer.amount;
      }
    }
  });

  return result;
};

const calculateTodaySpent = (transfers) => {
  let result = 0;

  transfers.forEach((transfer) => {
    if (transfer.action === 0 || transfer.action === 2) {
      if (formatDate(transfer.date) === formatDate(Date.now())) {
        result += transfer.amount;
      }
    }
  });

  return result;
};

const commonCalculateSpentMonth = (commonTransfers) => {
  let result = 0;

  commonTransfers.forEach((transfer) => {
    if (transfer.action === 0 || transfer.action === 2) {
      const days = Math.abs(
        Math.ceil(
          (new Date(transfer.date).getTime() - today.getTime()) /
            (1000 * 3600 * 24)
        )
      );

      if (days <= 30) {
        result += transfer.amount;
      }
    }
  });

  return result;
};

const commonCalculateEarningMonth = (commonTransfers) => {
  let result = 0;
  commonTransfers.forEach((transfer) => {
    if (transfer.action === 1) {
      const days = Math.abs(
        Math.ceil(
          (new Date(transfer.date).getTime() - today.getTime()) /
            (1000 * 3600 * 24)
        )
      );

      if (days <= 30) {
        result += transfer.amount;
      }
    }
  });

  return result;
};

const notify = (message) => {
  return $.post(
    `https://${GetParentResourceName()}/sendNotification`,
    JSON.stringify({
      message: message,
    })
  );
};

/*
    Common bank app functions
*/

let playerData;
let currentCommonID;
let currentWindow;

let onlinePlayers = [];
let isUsingModal = false;

const today = new Date();
const availableWindows = new Map();

// Open the gui
const openGui = (data) => {
  playerData = data.playerData;
  onlinePlayers = data.onlinePlayers;

  setActiveWindow("account-selection");
};

// Close the gui
const closeGui = () => {
  hideCurrentWindow();

  const element = document.getElementById("background");
  element.style.display = "none";
};

const loadTransactions = (callback) => {
  $("#history").empty();

  let history = new Map();

  for (const transfer of Object.values(playerData.personalAccount.transfers)) {
    const days = Math.abs(
      Math.ceil(
        (new Date(transfer.date).getTime() - today.getTime()) /
          (1000 * 3600 * 24)
      )
    );

    if (days <= CONFIG.lastTransactionDays) {
      if (!history.has(formatDate(transfer.date))) {
        history.set(formatDate(transfer.date), []);
      }

      const element = history.get(formatDate(transfer.date));

      element.push({
        date: formatTime(new Date(transfer.date)),
        amount: transfer.amount,
        action: transfer.action,
        serviceID: transfer.serviceID,
      });

      history.set(formatDate(transfer.date), element);
    }
  }

  history.forEach((value, key) => {
    $("#history").append(`<h2>${key}</h2>`);
    $("#history").append("<hr>");

    value.forEach((element) => {
      $("#history").append(`
                <li>
                    <img src="${
                      CONFIG.servicesType[element.serviceID - 1].icon
                    }"> 
                    <h3>${CONFIG.servicesType[element.serviceID - 1].name}</h3>
                    <p>${element.date}</p>
                    <p><strong style="color: ${
                      COLOURS_TYPES[element.action].color
                    } !important">${COLOURS_TYPES[element.action].indicator} ${
        element.amount
      }$</strong></p>
                </li>
            `);
    });
  });

  if (callback) {
    callback();
  }
};

const loadCommonTransactions = (callback) => {
  $("#history-common").empty();

  let history = new Map();

  for (const [transferID, transfer] of Object.entries(
    playerData.commonAccounts[currentCommonID].transfers
  )) {
    const days = Math.abs(
      Math.ceil(
        (new Date(transfer.date).getTime() - today.getTime()) /
          (1000 * 3600 * 24)
      )
    );

    if (days < CONFIG.lastTransactionDays) {
      if (!history.has(formatDate(transfer.date))) {
        history.set(formatDate(transfer.date), []);
      }

      const element = history.get(formatDate(transfer.date));

      element.push({
        date: formatTime(new Date(transfer.date)),
        owner: transfer.ownerName,
        amount: transfer.amount,
        action: transfer.action,
      });

      history.set(formatDate(transfer.date), element);
    }
  }

  history.forEach((value, key) => {
    $("#history-common").append(`<h2>${key}</h2>`);
    $("#history-common").append("<hr>");

    value.forEach((element) => {
      $("#history-common").append(`
                <li>
                    <img src="icons/profile.svg"> 
                    <h3>${element.owner}</h3>
                    <p>${element.date}</p>
                    <p><strong style="color: ${
                      COLOURS_TYPES[element.action].color
                    } !important">${COLOURS_TYPES[element.action].indicator} ${
        element.amount
      }$</strong></p>
                </li>
            `);
    });
  });

  if (callback) {
    callback();
  }
};

const onDeleteCommonAccount = () => {
  fetch(`https://${GetParentResourceName()}/deleteCommonAccount`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify({
      accountID: currentCommonID,
    }),
  }).then((success) => {
    if (success) delete playerData.commonAccounts[currentCommonID];
    currentCommonID = null;

    hideCurrentWindow();
    setActiveWindow("main-interface");
  });
};

availableWindows.set("delete-common-account", onDeleteCommonAccount);

let i2 = 8;

const onPlayerAddedToAccount = () => {
  fetch(`https://${GetParentResourceName()}/addPlayerToAccount`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify({
      target: $("#common-online-players").val(),
      accountID: currentCommonID,
    }),
  })
    .then((response) => response.json())
    .then((data) => {
      data = JSON.parse(data);
      if (!data) return notify("A problem occurred during processing.");

      if (data.success) {
        i2++;

        const member = JSON.parse($("#common-online-players").val());
        member.identifier = data.targetIdentifier;

        $("#profiles").append(`
                <a class="profile" id="profile-${i2}">
                    <svg width="40" height="38" viewBox="0 0 64 62" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M32 0.826086C27.6364 0.826086 24.2273 2.43433 21.7727 5.65081C19.3182 8.8673 18.0909 12.9789 18.0909 17.9857C18.0606 24.2063 20.0606 29.1372 24.0909 32.7785C24.6061 33.264 24.7879 33.8861 24.6364 34.6447L23.5909 36.8295C23.2576 37.5577 22.7652 38.1267 22.1136 38.5363C21.4621 38.946 20.0909 39.5301 18 40.2887C17.9091 40.3191 15.9924 40.9411 12.25 42.1549C8.50758 43.3687 6.51515 44.0362 6.27273 44.1576C3.72727 45.2197 2.06061 46.3272 1.27273 47.4803C0.424242 49.392 0 54.2319 0 62H64C64 54.2319 63.5758 49.392 62.7273 47.4803C61.9394 46.3272 60.2727 45.2197 57.7273 44.1576C57.4849 44.0362 55.4924 43.3687 51.75 42.1549C48.0076 40.9411 46.0909 40.3191 46 40.2887C43.9091 39.5301 42.5379 38.946 41.8864 38.5363C41.2348 38.1267 40.7424 37.5577 40.4091 36.8295L39.3636 34.6447C39.2121 33.8861 39.3939 33.264 39.9091 32.7785C43.9394 29.1372 45.9394 24.2063 45.9091 17.9857C45.9091 12.9789 44.6818 8.8673 42.2273 5.65081C39.7727 2.43433 36.3636 0.826086 32 0.826086Z" fill="#E9EEF3"/>
                    </svg>
                    <p>${member.name}</p>
                    <div class="delete-member">Supprimer</div>
                </a>
            `);

        $(`#profile-${i2}`).click(() => {
          fetch(`https://${GetParentResourceName()}/removeCommonUser`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json; charset=UTF-8",
            },
            body: JSON.stringify({
              member: member,
              accountID: currentCommonID,
            }),
          })
            .then((response) => response.json())
            .then((success) => {
              if (success) {
                $(`#profile-${i2}`).remove();
              }
            });
        });
      }
    });
};

availableWindows.set("common-add-player", onPlayerAddedToAccount);

/* 
    Available windows
*/

const showMain = () => {
  hideCurrentWindow();

  const centerCommonAccounts = document.getElementById(
    "center-common-accounts"
  );
  if (!centerCommonAccounts) return;

  centerCommonAccounts.innerHTML = "";

  const commonLength = playerData.commonAccounts
    ? Object.keys(playerData.commonAccounts).length
    : 0;

  if (commonLength > 0) {
    for (const [accountID, account] of Object.entries(
      playerData.commonAccounts
    )) {
      $("#center-common-accounts").append(`
                <a class="custom-account" id="connect-common" data-accountID="${accountID}">
                    <svg class="disabled" width="60" height="37" viewBox="0 0 60 37" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M30 0C27.6794 0 25.4538 0.974551 23.8128 2.70926C22.1719 4.44397 21.25 6.79675 21.25 9.25C21.25 11.7033 22.1719 14.056 23.8128 15.7907C25.4538 17.5254 27.6794 18.5 30 18.5C32.3206 18.5 34.5462 17.5254 36.1872 15.7907C37.8281 14.056 38.75 11.7033 38.75 9.25C38.75 6.79675 37.8281 4.44397 36.1872 2.70926C34.5462 0.974551 32.3206 0 30 0ZM30 5.28571C30.9946 5.28571 31.9484 5.70338 32.6516 6.44683C33.3549 7.19027 33.75 8.19861 33.75 9.25C33.75 10.3014 33.3549 11.3097 32.6516 12.0532C31.9484 12.7966 30.9946 13.2143 30 13.2143C29.0054 13.2143 28.0516 12.7966 27.3483 12.0532C26.6451 11.3097 26.25 10.3014 26.25 9.25C26.25 8.19861 26.6451 7.19027 27.3483 6.44683C28.0516 5.70338 29.0054 5.28571 30 5.28571ZM13.75 7.92857C12.0924 7.92857 10.5027 8.62468 9.33058 9.86376C8.15848 11.1028 7.5 12.7834 7.5 14.5357C7.5 17.02 8.825 19.1607 10.725 20.2971C11.625 20.8257 12.65 21.1429 13.75 21.1429C14.85 21.1429 15.875 20.8257 16.775 20.2971C17.7 19.7421 18.475 18.9493 19.05 17.9979C17.2287 15.4887 16.2442 12.4128 16.25 9.25V8.51C15.5 8.14 14.65 7.92857 13.75 7.92857ZM46.25 7.92857C45.35 7.92857 44.5 8.14 43.75 8.51V9.25C43.75 12.4214 42.775 15.4871 40.95 17.9979C41.25 18.5 41.575 18.8964 41.95 19.2929C43.1029 20.4745 44.6442 21.1376 46.25 21.1429C47.35 21.1429 48.375 20.8257 49.275 20.2971C51.175 19.1607 52.5 17.02 52.5 14.5357C52.5 12.7834 51.8415 11.1028 50.6694 9.86376C49.4973 8.62468 47.9076 7.92857 46.25 7.92857ZM30 23.7857C24.15 23.7857 12.5 26.8779 12.5 33.0357V37H47.5V33.0357C47.5 26.8779 35.85 23.7857 30 23.7857ZM11.775 25.2393C6.95 25.8471 0 28.4371 0 33.0357V37H7.5V31.8993C7.5 29.23 9.225 27.01 11.775 25.2393ZM48.225 25.2393C50.775 27.01 52.5 29.23 52.5 31.8993V37H60V33.0357C60 28.4371 53.05 25.8471 48.225 25.2393ZM30 29.0714C33.825 29.0714 38.1 30.3929 40.575 31.7143H19.425C21.9 30.3929 26.175 29.0714 30 29.0714Z" fill="#B8B8B8"/>
                    </svg>
                </a>
            `);
    }
  }

  for (let i = 0; i < 3 - commonLength; i++) {
    $("#center-common-accounts").append(`
            <a class="custom-account" id="create-common">
                <svg class="disabled" width="49" height="49" viewBox="0 0 49 49" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path class="disabled" d="M24.5 6.125C34.6063 6.125 42.875 14.3938 42.875 24.5C42.875 34.6063 34.6063 42.875 24.5 42.875C14.3938 42.875 6.125 34.6063 6.125 24.5C6.125 14.3938 14.3938 6.125 24.5 6.125ZM24.5 3.0625C12.7094 3.0625 3.0625 12.7094 3.0625 24.5C3.0625 36.2906 12.7094 45.9375 24.5 45.9375C36.2906 45.9375 45.9375 36.2906 45.9375 24.5C45.9375 12.7094 36.2906 3.0625 24.5 3.0625Z" fill="#B8B8B8"/>
                    <path d="M36.75 22.9688H26.0312V12.25H22.9688V22.9688H12.25V26.0312H22.9688V36.75H26.0312V26.0312H36.75V22.9688Z" fill="#B8B8B8"/>
                </svg>
            </a>
        `);
  }

  // hide other things
  /*$("#account-register").css("display", "none");
    $("#account-connection").css("display", "none");
    $("#main-interface").css("display", "none");
    $("#navbar").css("display", "none");*/

  $("#background").css("display", "block");
  $("#login-interface").css("display", "block");
  $("#account-selection").css("display", "block");
  $("#account").css("display", "block");
};

availableWindows.set("account-selection", showMain);

const loginIntoAccount = () => {
  const password = $("#input-password").val();

  if (password === "") {
    return notify(
      "The password must contain at least 1 character~w~."
    );
  }

  fetch(`https://${GetParentResourceName()}/loginPersonalAccount`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify({
      password: password,
    }),
  })
    .then((response) => response.json())
    .then((canConnect) => {
      if (canConnect) {
        notify("~g~Connect~w~ in progress..");

        hideCurrentWindow();
        setActiveWindow("main-interface");
      } else {
        notify("The password is ~r~incorrect~w~.");
      }
    });
};

availableWindows.set("login-button", loginIntoAccount);

const registerAccount = () => {
  const password = $("#new-password").val();

  if (password !== $("#confirm-password").val()) {
    return notify("The password must contain at least 1 character~w~");
  }

  if (password === "") {
    return notify(
      "The password must contain at least 1 character~w~."
    );
  }

  fetch(`https://${GetParentResourceName()}/registerAccount`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify({
      accountType: 0,
      password: password,
    }),
  })
    .then((response) => response.json())
    .then((updatedPlayerData) => {
      updatedPlayerData = JSON.parse(updatedPlayerData);

      if (!updatedPlayerData) {
        return notify(
          "A ~r~problem occurred ~w~while creating the account."
        );
      }

      playerData = updatedPlayerData.playerData;

      hideCurrentWindow();
      setActiveWindow("main-interface");

      return notify("Account created with ~g~success ~w~!");
    });
};

availableWindows.set("register-button", registerAccount);

const showConnectionMenu = () => {
  hideCurrentWindow();

  $("#login-interface").css("display", "block");

  if (!playerData.personalAccount) {
    $("#account-register").css("display", "block");
  } else {
    $("#account-connection").css("display", "block");
  }
};

availableWindows.set("account", showConnectionMenu);

/*
    Common Account Creation
*/

const showCommonCreationMenu = () => {
  $("#account-selection").css("display", "none");
  $("#create-common-players").empty();

  onlinePlayers.forEach((player) => {
    if (!player.isCurrentUser) {
      $("#create-common-players").append(
        $("<option>", {
          value: JSON.stringify(player),
          text: player.name,
        })
      );
    }
  });

  $("#account-common-register").css("display", "block");
};

availableWindows.set("create-common", showCommonCreationMenu);

let clicked = false;

const onCreateCommonAccount = () => {
  if (clicked) return;
  clicked = true;

  let members = [];

  $("#create-common-players option:selected").each(function () {
    members.push($(this).val());
  });

  fetch(`https://${GetParentResourceName()}/registerAccount`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify({
      members: members,
      accountType: 1,
    }),
  })
    .then((response) => response.json())
    .then((data) => {
      data = JSON.parse(data);
      if (!data) return notify("A problem occurred during processing.");

      if (data.memberAlreadyTaken) {
        return notify(
          "A member you have chosen already has 3 common accounts~w~."
        );
      }

      playerData = data.playerData;
      currentCommonID = data.currentCommonID;

      $("#account-common-register").css("display", "none");
      $("#login-interface").css("display", "none");

      hideCurrentWindow();
      setActiveWindow("connect-common");

      clicked = false;
    });
};

availableWindows.set("create-common-button", onCreateCommonAccount);

/*
    Interfaces
*/

const loadMainInterface = () => {
  loadTransactions(() => {
    $("#main-spent-month").text(
      "- " + calculateSpentMonth(playerData.personalAccount.transfers) + "$"
    );
    $("#main-spent-week").text(
      "- " + calculateSpentWeek(playerData.personalAccount.transfers) + "$"
    );
    $("#main-earning-today").text(
      calculateTodayEarning(playerData.personalAccount.transfers) + "$"
    );
    $("#main-spent-today").text(
      calculateTodaySpent(playerData.personalAccount.transfers) + "$"
    );
  });

  $("#main-firstname").text(playerData.firstname);
  $("#main-lastname").text(playerData.lastname);
  $("#main-balance").text(playerData.personalAccount.balance + "$");

  $("#login-interface").css("display", "none");
  $("#main-interface").css("display", "block");
  $("#nav-home").addClass("active");
  $("#nav-common").removeClass("active");
  $("#navbar").css("display", "block");

  notify("~g~Connected~w~ !");
};

availableWindows.set("main-interface", loadMainInterface);

const loadCommonInterface = (dataset) => {
  hideCurrentWindow();

  if (dataset) {
    currentCommonID = parseInt(dataset.accountid);
  }

  const account = playerData.commonAccounts[currentCommonID];
  if (!account) return console.log("common account not found");

  if (account.owner !== playerData.identifier) {
    $("#choose-add-player").css("display", "none");
    $("#delete-common-account").css("display", "none");
    $("#buttons-container").css("margin-top", "50px");
  } else {
    $("#delete-common-account").css("display", "table");
    $("#choose-add-player").css("display", "block");
    $("#buttons-container").css("margin-top", "50px");
    $("#choose-add-player").css("margin-top", "0");
  }
  $("#common-solde").text(account.balance + "$");

  loadCommonTransactions(() => {
    $("#common-spent-money").text(
      "- " + commonCalculateSpentMonth(account.transfers) + "$"
    );
    $("#common-earn-money").text(
      "+ " + commonCalculateEarningMonth(account.transfers) + "$"
    );
  });

  $("#profiles").empty();

  const members = account.members;

  $("#profiles").append(`
        <a class="profile" id="profile-0">
            <svg width="40" height="38" viewBox="0 0 64 62" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M32 0.826086C27.6364 0.826086 24.2273 2.43433 21.7727 5.65081C19.3182 8.8673 18.0909 12.9789 18.0909 17.9857C18.0606 24.2063 20.0606 29.1372 24.0909 32.7785C24.6061 33.264 24.7879 33.8861 24.6364 34.6447L23.5909 36.8295C23.2576 37.5577 22.7652 38.1267 22.1136 38.5363C21.4621 38.946 20.0909 39.5301 18 40.2887C17.9091 40.3191 15.9924 40.9411 12.25 42.1549C8.50758 43.3687 6.51515 44.0362 6.27273 44.1576C3.72727 45.2197 2.06061 46.3272 1.27273 47.4803C0.424242 49.392 0 54.2319 0 62H64C64 54.2319 63.5758 49.392 62.7273 47.4803C61.9394 46.3272 60.2727 45.2197 57.7273 44.1576C57.4849 44.0362 55.4924 43.3687 51.75 42.1549C48.0076 40.9411 46.0909 40.3191 46 40.2887C43.9091 39.5301 42.5379 38.946 41.8864 38.5363C41.2348 38.1267 40.7424 37.5577 40.4091 36.8295L39.3636 34.6447C39.2121 33.8861 39.3939 33.264 39.9091 32.7785C43.9394 29.1372 45.9394 24.2063 45.9091 17.9857C45.9091 12.9789 44.6818 8.8673 42.2273 5.65081C39.7727 2.43433 36.3636 0.826086 32 0.826086Z" fill="#E9EEF3"/>
            </svg>
            <p>${account.ownerName}</p> 
            <div class="blue-button">Propriétaire</div>
        </a>
    `);

  let i = 1;

  members.forEach((member) => {
    $("#profiles").append(`
            <a class="profile" id="profile-${i}">
                <svg width="40" height="38" viewBox="0 0 64 62" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M32 0.826086C27.6364 0.826086 24.2273 2.43433 21.7727 5.65081C19.3182 8.8673 18.0909 12.9789 18.0909 17.9857C18.0606 24.2063 20.0606 29.1372 24.0909 32.7785C24.6061 33.264 24.7879 33.8861 24.6364 34.6447L23.5909 36.8295C23.2576 37.5577 22.7652 38.1267 22.1136 38.5363C21.4621 38.946 20.0909 39.5301 18 40.2887C17.9091 40.3191 15.9924 40.9411 12.25 42.1549C8.50758 43.3687 6.51515 44.0362 6.27273 44.1576C3.72727 45.2197 2.06061 46.3272 1.27273 47.4803C0.424242 49.392 0 54.2319 0 62H64C64 54.2319 63.5758 49.392 62.7273 47.4803C61.9394 46.3272 60.2727 45.2197 57.7273 44.1576C57.4849 44.0362 55.4924 43.3687 51.75 42.1549C48.0076 40.9411 46.0909 40.3191 46 40.2887C43.9091 39.5301 42.5379 38.946 41.8864 38.5363C41.2348 38.1267 40.7424 37.5577 40.4091 36.8295L39.3636 34.6447C39.2121 33.8861 39.3939 33.264 39.9091 32.7785C43.9394 29.1372 45.9394 24.2063 45.9091 17.9857C45.9091 12.9789 44.6818 8.8673 42.2273 5.65081C39.7727 2.43433 36.3636 0.826086 32 0.826086Z" fill="#E9EEF3"/>
                </svg>
                <p>${member.name}</p>
                ${
                  account.owner === playerData.identifier
                    ? '<div class="delete-member">Supprimer</div>'
                    : ""
                }
                
            </a>
        
            `);

    $(`#profile-${i}`).click(() => {
      fetch(`https://${GetParentResourceName()}/removeCommonUser`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify({
          member: member,
          accountID: currentCommonID,
        }),
      })
        .then((response) => response.json())
        .then((success) => {
          if (success) {
            $(`#profile-${i}`).remove();
          }
        });
    });
  });

  $("#common-online-players").empty();

  onlinePlayers.forEach((player) => {
    if (!player.isCurrentUser) {
      $("#common-online-players").append(
        $("<option>", {
          value: JSON.stringify(player),
          text: player.name,
        })
      );
    }
  });

  $("#main-common-interface").css("display", "block");
  $("#nav-home").removeClass("active");
  $("#nav-common").addClass("active");
  $("#navbar").css("display", "block");
};

availableWindows.set("connect-common", loadCommonInterface);

availableWindows.set("nav-login", showMain);

const onNavbarHome = () => {
  hideCurrentWindow();
  loadMainInterface();
};

availableWindows.set("nav-home", onNavbarHome);

const onNavCommon = () => {
  hideCurrentWindow();

  if (!currentCommonID) {
    return setActiveWindow("main-interface");
  }

  setActiveWindow("connect-common");
};

availableWindows.set("nav-common", onNavCommon);

/*
    Remove money
*/

const removePersonalMoney = () => {
  isUsingModal = true;

  $("#modal-name").text("Retrait d'argent");
  $("#navbar").css("display", "none");
  $("#layout-modal").css("display", "block");
  $("#modal-transfer").css("display", "none");
  $("#modal-add").css("display", "none");
  $("#modal-remove").css("display", "inline-grid");
};

availableWindows.set("main-remove-money", removePersonalMoney);
availableWindows.set("main-common-remove-money", removePersonalMoney);

const onRemoveMoney = () => {
  if (!conform($("#modal-remove-input").val())) {
    return notify("The amount must contain ~r~only numbers~w~.");
  }

  const isPersonalAccount = $("#main-interface").css("display") === "block";
  const body = isPersonalAccount
    ? {
        amount: parseInt($("#modal-remove-input").val()),
        accountType: 0,
      }
    : {
        amount: parseInt($("#modal-remove-input").val()),
        accountID: currentCommonID,
        accountType: 1,
      };

  fetch(`https://${GetParentResourceName()}/removeMoney`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify(body),
  })
    .then((data) => data.json())
    .then((data) => {
      playerData = JSON.parse(data);
      if (!playerData)
        return notify("A problem occurred during processing.");

      if (isPersonalAccount) {
        $("#main-balance").text(
          parseFloat($("#main-balance").text()) -
            parseFloat($("#modal-remove-input").val()) +
            "$"
        );

        loadTransactions(() => {
          $("#main-spent-month").text(
            "- " +
              calculateSpentMonth(playerData.personalAccount.transfers) +
              "$"
          );
          $("#main-spent-week").text(
            "- " +
              calculateSpentWeek(playerData.personalAccount.transfers) +
              "$"
          );
          $("#main-spent-today").text(
            calculateTodaySpent(playerData.personalAccount.transfers) + "$"
          );
        });
      } else {
        $("#common-solde").text(
          parseFloat($("#common-solde").text()) -
            parseFloat($("#modal-remove-input").val()) +
            "$"
        );

        loadCommonTransactions(() => {
          $("#common-spent-money").text(
            "- " +
              commonCalculateSpentMonth(
                playerData.commonAccounts[currentCommonID].transfers
              ) +
              "$"
          );
        });
      }
    });

  isUsingModal = false;

  hideModal();
  $("#navbar").css("display", "block");
};

availableWindows.set("modal-remove-valid", onRemoveMoney);

/*
    Add money
*/

const addMoney = () => {
  isUsingModal = true;

  $("#modal-name").text("Dépôt d'argent");
  $("#navbar").css("display", "none");
  $("#layout-modal").css("display", "block");
  $("#modal-remove").css("display", "none");
  $("#modal-transfer").css("display", "none");
  $("#modal-add").css("display", "inline-grid");
};

availableWindows.set("main-add-money", addMoney);
availableWindows.set("main-common-add-money", addMoney);

const onAddMoney = () => {
  if (!conform($("#modal-add-input").val())) {
    return notify("The amount must contain ~r~only numbers~w~.");
  }

  const personalAccount = $("#main-interface").css("display") === "block";
  const body = personalAccount
    ? {
        amount: parseInt($("#modal-add-input").val()),
        accountType: 0,
      }
    : {
        amount: parseInt($("#modal-add-input").val()),
        accountID: currentCommonID,
        accountType: 1,
      };

  fetch(`https://${GetParentResourceName()}/addMoney`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify(body),
  })
    .then((data) => data.json())
    .then((data) => {
      playerData = JSON.parse(data);
      if (!playerData)
        return notify("A problem occurred during processing.");

      if (personalAccount) {
        const amount = parseFloat($("#modal-add-input").val());
        $("#main-balance").text(
          parseFloat($("#main-balance").text()) + amount + "$"
        );

        loadTransactions(() => {
          $("#main-earning-today").text(
            calculateTodayEarning(playerData.personalAccount.transfers) + "$"
          );
        });
      } else {
        $("#common-solde").text(
          parseFloat($("#common-solde").text()) +
            parseFloat($("#modal-add-input").val()) +
            "$"
        );

        loadCommonTransactions(() => {
          $("#common-earn-money").text(
            "+ " +
              commonCalculateEarningMonth(
                playerData.commonAccounts[currentCommonID].transfers
              ) +
              "$"
          );
        });
      }
    });

  isUsingModal = false;

  hideModal();
  $("#navbar").css("display", "block");
};

availableWindows.set("modal-add-valid", onAddMoney);

/*
    Transfer money
*/

const transferMoney = (isCommonAccount) => {
  isUsingModal = true;

  $("#modal-name").text("Transfert d'argent");
  $("#navbar").css("display", "none");
  $("#layout-modal").css("display", "block");
  $("#modal-add").css("display", "none");
  $("#modal-remove").css("display", "none");
  $("#modal-transfer-select").empty();

  onlinePlayers.forEach((player) => {
    if (isCommonAccount === true) {
      // avoid conflict with dataset
      $("#modal-transfer-select").append(
        $("<option>", {
          value: JSON.stringify(player),
          text: player.name,
        })
      );
    } else if (!player.isCurrentUser) {
      console.log("current:");
      console.log(player.isCurrentUser);

      $("#modal-transfer-select").append(
        $("<option>", {
          value: JSON.stringify(player),
          text: player.name,
        })
      );
    }
  });

  $("#modal-transfer").css("display", "inline-grid");
};

availableWindows.set("main-transfer-money", transferMoney);
availableWindows.set("main-common-transfer-money", () => transferMoney(true));

const onTransferMoney = () => {
  if (!conform($("#modal-transfer-input").val())) {
    return notify("The amount must contain ~r~only numbers~w~.");
  }

  const personalAccount = $("#main-interface").css("display") === "block";
  const body = personalAccount
    ? {
        amount: parseInt($("#modal-transfer-input").val()),
        target: $("#modal-transfer-select").val(),
        accountType: 0,
      }
    : {
        amount: parseInt($("#modal-transfer-input").val()),
        target: $("#modal-transfer-select").val(),
        accountID: currentCommonID,
        accountType: 1,
      };

  fetch(`https://${GetParentResourceName()}/transferMoney`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify(body),
  }).then((data) =>
    data.json().then((data) => {
      playerData = JSON.parse(data);
      if (!playerData)
        return notify("A problem occurred during processing.");

      if (personalAccount) {
        $("#main-balance").text(
          parseFloat($("#main-balance").text()) -
            parseFloat($("#modal-transfer-input").val()) +
            "$"
        );

        loadTransactions(() => {
          $("#main-spent-month").text(
            "- " +
              calculateSpentMonth(playerData.personalAccount.transfers) +
              "$"
          );
          $("#main-spent-week").text(
            "- " +
              calculateSpentWeek(playerData.personalAccount.transfers) +
              "$"
          );
          $("#main-spent-today").text(
            calculateTodaySpent(playerData.personalAccount.transfers) + "$"
          );
        });
      } else {
        $("#common-solde").text(
          parseFloat($("#common-solde").text()) -
            parseFloat($("#modal-transfer-input").val()) +
            "$"
        );

        loadCommonTransactions(() => {
          $("#common-spent-money").text(
            "- " +
              commonCalculateSpentMonth(
                playerData.commonAccounts[currentCommonID].transfers
              ) +
              "$"
          );
        });
      }
    })
  );

  isUsingModal = false;

  hideModal();
  $("#navbar").css("display", "block");
};

availableWindows.set("modal-transfer-valid", onTransferMoney);

/*
    Window Manager
*/

const hideModal = () => {
  $("#layout-modal").css("display", "none");
  $("#modal-remove").css("display", "none");
};

const hideCurrentWindow = () => {
  $("#account-common-register").css("display", "none");
  $("#account-register").css("display", "none");
  $("#account-connection").css("display", "none");
  $("#account-selection").css("display", "none");

  document.getElementById("background").childNodes.forEach((node) => {
    if (
      node.dataset &&
      node.dataset.shouldbehide &&
      node.style &&
      node.style.display === "block"
    ) {
      node.style.display = "none";
    }
  });
};

// Change current scene
const setActiveWindow = (window, dataset) => {
  if (!window) return;
  if (!availableWindows.has(window)) return;

  availableWindows.get(window)(dataset);

  currentWindow = window;
};

/*
    Handle incoming messages, events
*/

const handleData = (data) => {
  switch (data.action) {
    case "open":
      openGui(data.data);
      break;
    case "close":
      closeGui();
      break;
    default:
      break;
  }
};

window.addEventListener("message", (event) => handleData(event.data));

document.onkeyup = function (data) {
  if (data.which === 27 || data.which === 8) {
    if (isUsingModal && !(document.activeElement instanceof HTMLInputElement)) {
      isUsingModal = false;

      $("#layout-modal").css("display", "none");
      $("#navbar").css("display", "block");
    } else if (!(document.activeElement instanceof HTMLInputElement)) {
      $.post("https://banking-system/closeMenu", JSON.stringify({}));
    }
  }
};

document.addEventListener(
  "click",
  function (e) {
    e = e || window.event;

    const target = e.target || e.srcElement,
      text = target.textContent || target.innerText;

    setActiveWindow(target.id, target.dataset);
  },
  false
);
