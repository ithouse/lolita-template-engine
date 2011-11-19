
$(function(){
  var _activated_cb = [];
  var _enabled_ph_class = ".placeholder.enabled"
  var _all_ph_class = ".placeholder"
  var _disabled_ph_class = ".placeholder.disabled"
  

  //Check if content block fits in placeholder.
  //When placeholder are allowed to stretch vertically or horizontally then checking of height or width are skipped.
  function fit_in_placeholder(placeholder,content_block){
   
    var p_width = placeholder.width() ;
    var p_height = placeholder.height();
    var p_stretch = placeholder.data("stretch")
    var result = true
    if(p_stretch!="vertically"){
      result = result && p_height <=parseInt(placeholder.data("height"))
    }
    if(p_stretch!="horizontally"){
      result = result && content_block.width() <= p_width && p_width <= parseInt(placeholder.data("width"))
    }else{
      if(content_block.width() > p_width){
        placeholder.width(content_block.width())
      }
    }
    return result
  }
 
  //Reset content block look
  function reset_block($block){
    $block.removeClass("active");
    $block.addClass("inactive")
    $block.height($block.data("old-height"));
    $block.width($block.data("old-width"))
    return $block
  }

  // Add clone back in content blocks list and revert look to original.
  function add_clone($clone){
    if($clone.data("domPositionPrev")){
      $clone.data("domPositionObj").after($clone)
    }else{
      $clone.data("domPositionObj").prepend($clone)
    }
    $clone.data("domPositionPrev",false)
    $clone.data("domPositionObj",false)
    return reset_block($clone)
  }

  //Make sortable placeholders look like content block
  function fix_real_placeholder(ui){
    $block = ui.item
    $real_ph = $(".inner-placeholder")
    $real_ph.width($block.width());
    $real_ph.height($block.height());  
    $real_ph.css("cssFloat","left")
  }

  $("#themes-select select").change(function(){
    var current_theme = $(this).children("option:selected").eq(0).val();
    var url = $(this).data("url").replace("-theme-",current_theme != "" ? current_theme : "_empty_")
    $.ajax({
      url: url,
      type: "get",
      dataType:"html",
      success:function(html){
        if(html==""){
          $("#content-blocks-container").html("")
          $("#placeholders-form .placeholders-grid").html("")
        }else{
          $("#content-blocks-container").replaceWith(html)
          initialize_sortables()
        }
      }
    })
  })
  $("#layouts-select select").live("change",function(){
    var theme = $("#themes-select select>option:selected").eq(0).val()
    theme = theme != "" ? theme : "_empty_"
    var layout = $(this).children("option:selected").eq(0).val();
    layout = layout != "" ? layout : "_empty_"
    var url = $(this).data("url").replace("-theme-", theme).replace("-layout-",layout)
    $.ajax({
      url: url,
      type: "get",
      dataType: "html",
      success:function(html){
        if(html==""){
          $("#placeholders-form").html("")
        }else{
          $("#placeholders-form").replaceWith(html);
          initialize_placeholders();
          initialize_sortables() 
        }
      }
    })
  })

  function initialize_placeholders(){
    $(_all_ph_class).each(function(){
      $(this).css("width",$(this).data("width")+"px")
      $(this).css("min-height",($(this).data("height")+"px"))
    })
  }

  function initialize_sortables(){
    //Placeholders also are sortable but they only changes sortable placeholder look on start and check fitnes of 
    //block in placeholder.
    $(_enabled_ph_class).sortable({
      connectWith: _enabled_ph_class,
      placeholder: "inner-placeholder",
      cursor: "move",
      start:function(event,ui){
        
        fix_real_placeholder(ui)
      },
      stop: function(event,ui){
        
        var $block = ui.item;
        var $p_holder = ui.item.parent();
        if(!fit_in_placeholder($p_holder,$block)){
          $(this).sortable("cancel");
        }
      }
    }).disableSelection();

    $("#content-blocks").sortable({
      connectWith: _enabled_ph_class,
      placeholder: 'inner-placeholder',
      cursor: "move",
      items: ".content-block",
      //Block started state are changed to true and sortable placeholder look are changed to match block look.
      start:function(event,ui){
        ui.item.data("started",true)
        fix_real_placeholder(ui)
      },
      // When sorting stops system checks if block fits in container and if its true it is placed inside it
      // and clone of it are placed back in list with previous look. When it not fits in then sortable cancel
      // action is called and block look are restored.
      stop:function(event,ui){
        ui.item.data("started",false)
        var $block = ui.item;
        var $p_holder = ui.item.parent();
        if(!fit_in_placeholder($p_holder,$block)){
          $(this).sortable("cancel");
          reset_block($block)
        }else{
          var $clone = $block.clone(true);
          $block.unbind("mousedown")
          add_clone($clone) 
        }
      }
    }).disableSelection();
  }
  //Initialize placeholder dimensions
  initialize_placeholders();
  initialize_sortables();

   //Remove block on double click from placeholders
  $(".content-block.active").live("dblclick",function(){
    $(this).remove();
  })

  //When user press mouse button on contenblock in list it is changed to its real look. 
  // Also some information about original position in list and dimensions are stored.
  $("#content-blocks .content-block").live("mousedown",function(){
    var $new_block = $(this)
    _activated_cb.push(this)
    $new_block.data("domPositionPrev",$new_block.prev()[0] ? true : false)
    $new_block.data("domPositionObj", $new_block.prev()[0] ? $new_block.prev() :  $new_block.parent())
    $new_block.removeClass("inactive")
    $new_block.addClass("active")
    $new_block.data("old-width",$new_block.width()).data("old-height",$new_block.height())
    $new_block.width($new_block.attr("data-width"))
    $new_block.height($new_block.attr("data-height"))
  })

  // When user pressed mouse button and didn't start draging content block it is restored to its previous 
  // look when mouse button is released.
  $("body").mouseup(function(){
    while(_activated_cb.length>0){
      var current_cb = _activated_cb.shift()
      if(!$(current_cb).data("started")){
        reset_block($(current_cb)) 
      }
    } 
  })
})