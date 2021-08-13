$ ->
  $('.click_all_checkbox').click (e) ->
    if $('.click_all_checkbox').prop("checked")
      $('input[type=checkbox]').prop('checked', true);
    else
      $('input[type=checkbox]').prop('checked', false);
