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
            on_error(error);
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
        on_error(error);
    });
}
function GetPlayerInfoResult() {
    return JSON.stringify(playerInfo);
}
function GetVkData() {
    return JSON.stringify(playerData);
}

function HTML5_GetFrameSize() {
    const doc = document.documentElement || {};
    const body = document.body || {};
    const viewport = window.visualViewport || {};
    const canvas = document.querySelector("canvas");
    const canvasRect = canvas ? canvas.getBoundingClientRect() : {};
    const parent = canvas ? canvas.parentElement : null;
    const parentRect = parent ? parent.getBoundingClientRect() : {};
    const frame = window.frameElement;
    const frameRect = frame ? frame.getBoundingClientRect() : {};

    const innerWidth = Math.floor(window.innerWidth || 0);
    const innerHeight = Math.floor(window.innerHeight || 0);
    const viewportWidth = Math.floor(viewport.width || 0);
    const viewportHeight = Math.floor(viewport.height || 0);
    const docWidth = Math.floor(doc.clientWidth || 0);
    const docHeight = Math.floor(doc.clientHeight || 0);
    const bodyWidth = Math.floor(body.clientWidth || 0);
    const bodyHeight = Math.floor(body.clientHeight || 0);
    const canvasClientWidth = Math.floor(canvas ? canvas.clientWidth || 0 : 0);
    const canvasClientHeight = Math.floor(canvas ? canvas.clientHeight || 0 : 0);
    const canvasRectWidth = Math.floor(canvasRect.width || 0);
    const canvasRectHeight = Math.floor(canvasRect.height || 0);
    const parentClientWidth = Math.floor(parent ? parent.clientWidth || 0 : 0);
    const parentClientHeight = Math.floor(parent ? parent.clientHeight || 0 : 0);
    const parentRectWidth = Math.floor(parentRect.width || 0);
    const parentRectHeight = Math.floor(parentRect.height || 0);
    const frameRectWidth = Math.floor(frameRect.width || 0);
    const frameRectHeight = Math.floor(frameRect.height || 0);

    let width = frameRectWidth || parentRectWidth || parentClientWidth || viewportWidth || innerWidth || docWidth || bodyWidth || canvasRectWidth || canvasClientWidth;
    let height = frameRectHeight || parentRectHeight || parentClientHeight || viewportHeight || innerHeight || docHeight || bodyHeight || canvasRectHeight || canvasClientHeight;
    width = Math.max(1, Math.floor(width || 0));
    height = Math.max(1, Math.floor(height || 0));

    return JSON.stringify({
        width: width,
        height: height,
        innerWidth: Math.max(1, innerWidth),
        innerHeight: Math.max(1, innerHeight),
        viewportWidth: viewportWidth,
        viewportHeight: viewportHeight,
        viewportScale: viewport.scale || 1,
        docWidth: docWidth,
        docHeight: docHeight,
        bodyWidth: bodyWidth,
        bodyHeight: bodyHeight,
        canvasWidth: canvas ? canvas.width || 0 : 0,
        canvasHeight: canvas ? canvas.height || 0 : 0,
        canvasClientWidth: canvasClientWidth,
        canvasClientHeight: canvasClientHeight,
        canvasRectWidth: canvasRectWidth,
        canvasRectHeight: canvasRectHeight,
        parentClientWidth: parentClientWidth,
        parentClientHeight: parentClientHeight,
        parentRectWidth: parentRectWidth,
        parentRectHeight: parentRectHeight,
        frameRectWidth: frameRectWidth,
        frameRectHeight: frameRectHeight
    });
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
