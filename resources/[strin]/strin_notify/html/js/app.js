window.addEventListener('message', function (event) {
    switch(event.data.action) {
        case 'short':
        case 'normal':
        case 'long':
        case 'custom':
            Notification(event.data);
            break;
        default:
            Notification(event.data);
            break;
    }
});

function Notification(data) {
    var $notify = $('.notification.template').clone();
    $notify.removeClass('template');
    $notify.addClass(data.type);
    $notify.html(data.text);
    $notify.fadeIn();
    $('.notif-container').append($notify);
    setTimeout(function() {
        $.when($notify.fadeOut()).done(function() {
            $notify.remove()
        });
    }, data.length != null ? data.length : 2500);
}