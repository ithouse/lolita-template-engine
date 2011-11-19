
$(function(){
  var _activated_cb = [];
  var _enabled_ph_class = ".placeholder.enabled"
  var _all_ph_class = ".placeholder"
  var _disabled_ph_class = ".placeholder.disabled"
  var _form_class = "#placeholders-form"
  
  function is_existing_layout(){
    $(".tabs").data("method") == "PUT"
  }

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

  // Return array of clones of _destroy inputs and id inputs, thoes can be used to add back to form
  function collect_removed_elements($blocks,skip_old){
    var clones = !skip_old ? collect_removed_elements($(_form_class + " #removed-cbs-container>div"),true) : []
    $blocks = $blocks || $(_form_class + " .content-block")
    $blocks.each(function(){
      var $destroy = $(this).children("input[id*='__destroy']:last")
      var $id = $(this).next()
      if($destroy.length>0 && $id[0] && $id[0].tagName.toLowerCase()=="input" && $id.attr("id").match(/_id$/)){
        clones.push([$destroy.clone(),$id.clone()])
      }
    })
    return clones
  }

  // Receive array of arrays, where each inner array container two jquery objects.
  // First is clone of _destroy input for removed content block and second is clone of id input of removed 
  // content block. It creates container with id 'removed-cbs-container' ad each _destroy input is put in
  // another div, so this DOM structure matches real form structure, for less complex logic for cloning in
  // #collect_removed_elements()
  function remove_blocks(block_clones){
    var $removed_container = $(_form_class+" #removed-cbs-container")
    if(!$removed_container[0]){
      $(_form_class).append("<div id='removed-cbs-container'></div>")
      $removed_container = $(_form_class).find("#removed-cbs-container")
    }
    $.each(block_clones,function(index,elements){
      elements[0].val(1)
      $removed_container.append("<div></div>")
      var $delete_container = $removed_container.find(":last")
      $delete_container.append(elements[0])
      $removed_container.append(elements[1])
    })
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
        }else{
          $("#content-blocks-container").replaceWith(html)
          initialize_sortables()
          set_layout_form_data(current_theme)
        }
        var clones = collect_removed_elements
        $(_form_class + " .placeholders-grid").html("")
        remove_blocks(clones)
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
        var clones = collect_removed_elements()
        if(html==""){
          $(_form_class).html(html)
        }else{
          var old_title = $("form #lolita_layout_title").val()
          $(_form_class).replaceWith(html);
          set_layout_form_data(theme,layout,old_title)
          initialize_placeholders();
          initialize_sortables() 
        }
        remove_blocks(clones)
      }
    })
  })

  function initialize_placeholders(){
    $(_all_ph_class).each(function(){
      $(this).css("width",$(this).data("width")+"px")
      $(this).css("min-height",($(this).data("height")+"px"))
    })
  }

  function rebuild_order_numbers_for($placeholder){
    $placeholder.find("input[id*='order_number']").each(function(index){
      $(this).val(index)
    })  
  }

  // Set theme namd and layout name in form
  function set_layout_form_data(theme,layout,title){
    $("#lolita_layout_theme_name").val(theme)
    $("#lolita_layout_name").val(layout)
    if(title){
      $("#lolita_layout_title").val(title)
    }  
  }

  // Copy form data form pre-defined placeholder nested form 
  // Add values to hidden fields about where CB is placed and what is its name
  function add_form_data($placeholder,$block){
    var form_data = $placeholder.data("form");
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + "layout_configurations", "g")
    form_data = form_data.replace(regexp,new_id)
    $block.append(form_data)
    $block.children("input[id*='predefined_block_name']").eq(0).val($block.data("name"))
    rebuild_order_numbers_for($placeholder)
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
        }else{
          rebuild_order_numbers_for($p_holder)
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
        if($p_holder.hasClass("placeholder") && fit_in_placeholder($p_holder,$block)){
          var $clone = $block.clone(true);
          $block.unbind("mousedown");
          add_form_data($p_holder,$block);
          add_clone($clone) 
        }else{
          $(this).sortable("cancel");
          reset_block($block)
        }
      }
    }).disableSelection();
  }
  //Initialize placeholder dimensions
  initialize_placeholders();
  initialize_sortables();

   //Remove block on double click from placeholders
  $(".content-block.active").live("dblclick",function(){
    var clones = collect_removed_elements($(this),true)
    var $id = $(this).next()
    if($id[0] && $id[0].tagName.toLowerCase()=="input" && $id.attr("id").match(/_id$/)){
      $id.remove()
    }
    var $placeholder = $(this).parents(".placeholder").eq(0)
    $(this).remove();
    remove_blocks(clones)
    rebuild_order_numbers_for($placeholder)
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