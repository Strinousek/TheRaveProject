$(() => {
    let selectedVehicle = 1
    const setNormalValues = () => {
        selectedVehicle = 1;
        $("#male-option").text("Muž");
        $("#female-option").text("Žena");
        //$("#gender-eyes-hair-label").text("Pohlaví, barva očí a barva vlasů");
        /*$("#eye-color").show();
        $("#hair-color").show();*/
        /*$("#weight-height-label").show();
        $("#weight-height-row").show();*/
        $("#vehicle-label").show();
        $("#vehicle-row").show();
    };

    const setAnimalValues = () => {
        $("#male-option").text("Samec");
        $("#female-option").text("Samice");
        //$("#gender-eyes-hair-label").text("Pohlaví");
        /*$("#eye-color").hide();
        $("#hair-color").hide();
        $("#weight-height-label").hide();
        $("#weight-height-row").hide();*/
        $("#vehicle-label").hide();
        $("#vehicle-row").hide();
    };
    window.addEventListener('message', (event) => {
        if (event.data.action == 'open') {
            setNormalValues();
            $('#container').show();
        } else if (event.data.action == 'close') {
            $('#container').hide();
        }
    });

    $("#char-type").change((e) => {
        const selected = $("#char-type > option:selected").val();
        if(selected == "animal") {
            setAnimalValues();
        } else if(selected == "normal" || selected == "ped")  {
            setNormalValues();
        }
    });

    $('input[type="number"]').on('keyup', (e) => {
        v = parseInt($(e.target).val());
        min = parseInt($(e.target).attr('min'));
        max = parseInt($(e.target).attr('max'));

        if (v > max){
            $(e.target).val(max);
        }
    })

    $('input[type="number"]').on('change', (e) => {
        v = parseInt($(e.target).val());
        min = parseInt($(e.target).attr('min'));
        max = parseInt($(e.target).attr('max'));

        if (v < min){
            $(e.target).val(min);
        }
    })

    $("#veh-1, #veh-2, #veh-3").on("click", (e) => {
        selectedVehicle = parseInt(e.target.id.replace("veh-", ""));
        $(`.selected-veh`).removeClass("selected-veh");
        $(`#veh-${selectedVehicle}`).addClass("selected-veh");
    });

    $('#submit-button').on("click", (e) => {
        let type = $("#char-type > option:selected").val();
        if (
            $('#lastname').val() != '' && 
            $('#firstname').val() != '' && 
            $('#dateofbirth').val() != '' && 
            $('#sex > option:selected').val() != "none" && 
            $('#char-type > option:selected').val() != "none" && 
            /*$('#eye-color > option:selected').val() != "none" && 
            $('#hair-color > option:selected').val() != "none" && */
            $('#height').val() != '' &&
            $('#weight').val() != ''
        ) {
            if ($('#height').val().length > 1 && $("#weight").val().length > 1 && $('#dateofbirth').val().length == 10) {
                $.post('https://strin_characters/register', JSON.stringify({
                    firstname: $("#firstname").val(),
                    lastname: $("#lastname").val(),
                    dateofbirth: $("#dateofbirth").val(),
                    /*eyes: $("#eye-color > option:selected").val(),
                    hairColor: $("#hair-color > option:selected").val(),*/
                    char_type: type == "normal" ? 1 : (type == "ped" ? 2 : 3),
                    car: selectedVehicle,
                    weight: parseInt($("#weight").val()),
                    sex: $("#sex > option:selected").val(),
                    height: parseInt($("#height").val())
                }));
            };
        };
    });
})