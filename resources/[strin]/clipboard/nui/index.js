window.onload = () => {
    window.addEventListener('message', function(event) {
        const textArea = document.createElement('textarea');
        const selection = document.getSelection();

        textArea.textContent = event.data.text;
        document.body.appendChild(textArea);

        selection.removeAllRanges();
        textArea.select();
        document.execCommand('copy');

        selection.removeAllRanges();
        document.body.removeChild(textArea);
    });
};
