$(document).on "ready page:load", ->
  $('input[name="member[occupation_id]"]:radio').on "change", ->
    $(".occupation_description").hide()
    $("#occupation_description_" + $(this).val()).show()
