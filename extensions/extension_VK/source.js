let playerData = {sign: 0, vk_user_id: 0};
let playerInfo = {};

function VKInit(on_success, on_error = () => {}) {
    loadScript('https://unpkg.com/@vkontakte/vk-bridge/dist/browser.min.js', function(err, script) {
        if (err) {
            on_error(err);
            return;
        }

        console.log("Инициализация VK");

        vkBridge.send("VKWebAppInit", {});
        //vkBridge.subscribe((e) => console.log(e)); 
        
        vkBridge.send('VKWebAppGetLaunchParams')
        .then((data) => { 
            if (data.vk_app_id) {
                playerData = data;
                console.log("data: " + data);
                on_success();
            } else {
                on_error();
            }
        })
        .catch((error) => {
            // Ошибка
            console.log(error);
        });
    });
}

function GetPlayerInfo(on_success, on_error = () => {}) {
    console.log("GetPlayerInfo");
    vkBridge.send('VKWebAppGetUserInfo', {user_id: playerData.vk_user_id})
    .then((data) => { 
        playerInfo = data;
        console.log(data);
        on_success();
    })
    .catch((error) => {
        // Ошибка
        console.log("error");
        console.log(error);
    });
}
function GetPlayerInfoResult() {
    return JSON.stringify(playerInfo);
}
function GetVkData() {
    return JSON.stringify(playerData);
}

function loadScript(url, callback) {
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = url;

    // Когда скрипт загрузится, вызываем колбэк
    script.onload = function() {
        console.log('Скрипт успешно загружен:', url);
        if (callback) callback(null, script);
    };

    // Обработка ошибок загрузки
    script.onerror = function(e) {
        console.error('Ошибка загрузки скрипта:', url, JSON.stringify(e), e);
        if (callback) callback(new Error('Failed to load script: ' + url));
    };

    // Добавляем скрипт в <head>
    document.getElementsByTagName('head')[0].appendChild(script);
}
