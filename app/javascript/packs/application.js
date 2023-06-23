// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("jquery");
require("@rails/ujs").start();
require("turbolinks").start();
require("@rails/activestorage").start();
require("channels");
require("bootstrap-datepicker");
require("bootstrap");
require('select2');
require("chartkick");
require("chart.js");
require("chartkick/chart.js");
import "../stylesheets/application";
import 'select2';
import 'select2/dist/css/select2.css';
import Chart from 'chart.js/auto';

global.Chart = Chart;

window.jQuery = $;
window.$ = $;

$(document).on("ajax:before ajaxStart page:fetch turbolinks:click turbolinks:load", function(event) {
    'use strict';

    $('[data-bs-toggle="tooltip"]').tooltip({html: true});
    $('.select2-dropdown').select2();
    $('.datepicker').datepicker({
        language: 'zh-CN',
        format: "yyyy-mm-dd",
        autoclose: true,
        forceParse: true,
        todayBtn: true,
        endDate: moment().toDate(),
        initialDate: moment().toDate()
    })

    if ($('.select_ranking_symbols').length > 0) {
        $('.select_ranking_symbols').off('change').on('change', function() {
            $('#rankingModal').modal('hide');
            var symbol = $(this).find("option:selected").text();
            var source = $(this).val();
            $.get('/ranking_snapshots/ranking_graph?symbol=' + symbol + '&source=' + source)
        })
    }

    if ($('.select_ranking_source').length > 0) {
        $('.select_ranking_source').on('change', function() {
            var source = $(this).val();
            location.href = '?source=' + source
        })
    }
});