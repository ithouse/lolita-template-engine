var LayoutConfig = {
  width: false,
  prevGridWidth: 0,
  init: true
}
function windowScrollDimensions(){
  var i = document.createElement('p');
  i.style.width = '100%';

  i.style.height = '200px';

  var o = document.createElement('div');
  o.style.position = 'absolute';
  o.style.top = '0px';
  o.style.left = '0px';
  o.style.visibility =
  'hidden';
  o.style.width = '200px';
  o.style.height = '150px';
  o.style.overflow = 'hidden';
  o.appendChild(i);

  document.body.appendChild(o);
  var w1 = i.offsetWidth;
  var
  h1 = i.offsetHeight;
  o.style.overflow = 'scroll';
  var w2 = i.offsetWidth;
  var h2 = i.offsetHeight;
  if (w1 == w2) w2 = o.clientWidth;
  if (h1 == h2) h2 = o.clientWidth;

  document.body.removeChild(o);

  window.scrollbarWidth = w1-w2;
  window.scrollbarHeight = h1-h2;
}

function isPlaceholder($element){
  return $element.hasClass("placeholder")
}

//Calculate grid width
function get_grid_width(){
  var $grid = $("#placeholders-form .placeholders-grid")
    
  var grid_width = $grid.eq(0).width();
  if($(window).height() >= $(document).height()){
    grid_width = grid_width - window.scrollbarWidth
  }  
  return grid_width
}

//Goes through all given elements and calculate they relative dimensions based on grid width.
//Store information inside block and change dimensions if neccessary
function resize_elements($elements, change_dimensions){
  if(parseInt(LayoutConfig.width) > 0){
    var grid_width = get_grid_width()
    //if(LayoutConfig.init || grid_width!=LayoutConfig.prevGridWidth){

      LayoutConfig.prevGridWidth = grid_width

      var diff = grid_width / LayoutConfig.width
      $elements.each(function(){
        var $block = $(this);
        var dimension_diff = 2
        var w = Math.floor(parseInt($block.attr("data-width")) * diff)-dimension_diff;
        var h = Math.floor(parseInt($block.attr("data-height")) * diff)-dimension_diff;
        $block.data("width",w)
        $block.data("height",h);
        if(change_dimensions){
          $block.width(w)
          if(isPlaceholder($block)){
            $block.css("min-height", h)
          }else{
            $block.height(h) 
          }
        }
      })
    //}
    return $elements
  }
}

//Calculate max possible font size for given element and parent element width and height.
function get_max_font_size($i,o_w,o_h){
  var c_f_size = parseInt($i.css("font-size"));
  var i_h = $i.height();
  var i_w = $i.width();
  $i.css("font-size",c_f_size+10+"px")
  var n_i_h = $i.height()
  var n_i_w = $i.width()
  var f_h_diff = (n_i_h-i_h) / 10
  var f_w_diff = (n_i_w - i_w) / 10
  var h_diff = o_h - i_h;
  var w_diff = o_w - i_w;
  var max_mult = Math.min(Math.floor(w_diff / f_w_diff), Math.floor(h_diff / f_h_diff))
  return max_mult + c_f_size
}

//Resize content blocks names that they fill smallest of dimensions and also center vertically it.
function center_spans($blocks){
  var grid_width = get_grid_width();
  //if($blocks || LayoutConfig.init || grid_width!=LayoutConfig.prevGridWidth ){

    LayoutConfig.prevGridWidth = grid_width;

    ($blocks || $(".content-block.active span:first-child")).each(function(){
      var $s = $(this)//.children("span").eq(0)
      var $p = $(this).parent();
      var $p_w = parseInt($p.data("width") - $p.data("width") * 0.1)
      var $p_h = $p.data("height")
      $s.css({opacity:0.1})
      $s.css("font-size",8);
      var new_f_size = get_max_font_size($s,$p_w,$p_h)
      
      $s.css("font-size", new_f_size)
      var top = Math.max(0, (($p.data("height") - $s.height())/2))
      $s.css("top",top+"px")
    })
  //}
}

// Goes through all placeholders and active content blocks and changes their attributes and dimensions.
// For inactive content blocks changes attributes but not dimensions and center spans inside active content blocks.
function resize_all_elements(){
  //var $active_blocks = $(".content-block.active")
  resize_elements($("#placeholders-form .placeholder"),true)
  resize_elements($(".content-block.active"),true);
  resize_elements($(".content-block.inactive"));
  center_spans()
  resize_elements($("#placeholders-form .placeholder"),true)
  //$(".content-block span.delete")
  LayoutConfig.init = false
}

$(window).resize(function(){
  resize_all_elements();
})

$(function(){
  windowScrollDimensions()
  var _activated_cb = [];
  var _enabled_ph_class = ".placeholder.enabled"
  var _all_ph_class = ".placeholder"
  var _disabled_ph_class = ".placeholder.disabled"
  var _form_class = "#placeholders-form"
  var _default_font_size = 13;
  
  function is_existing_layout(){
    $(".tabs").data("method") == "PUT"
  }

  //Detect if block is meant for placeholder, e.g., some blocks may be meant for specifict placeholders
  function block_meant_for_placeholder($p_holder,$block){
    return ($block.hasClass("fit-in-all") || $block.hasClass($p_holder.data("name")))
  }

  //Check if content block fits in placeholder.
  //When placeholder are allowed to stretch vertically or horizontally then checking of height or width are skipped.
  function fit_in_placeholder(placeholder,content_block){
    if(block_meant_for_placeholder(placeholder,content_block)){
      var p_width = parseInt(placeholder.attr("data-width")) ;
      var p_height = placeholder.height();
      var p_stretch = placeholder.data("stretch")
      var result = true
      if(p_stretch!="vertically"){
        result = result && p_height <=parseInt(placeholder.data("height"))
      }
      if(p_stretch!="horizontally"){
        result = result && content_block.attr("data-width") <= p_width && placeholder.width() <= parseInt(placeholder.data("width"))
      }else{
        if(content_block.width() > placeholder.width()){
          placeholder.width(content_block.width())
        }
      }
      return result 
    }else{
      return false
    }
  }
 
  //Reset content block look
  function reset_block($block){
    $block.removeClass("active");
    $block.addClass("inactive");
    $block.children("span:first").css({"font-size":_default_font_size,opacity:1})
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

  $(".nested-form-fields-container .controller_select").live("change",function(){
    var controller = $(this).children("option:selected").eq(0).val();
    var actions = ControllersActions[controller]
    var $action_select = $(this).siblings(".action_select").eq(0)
    $action_select.html('<option></option>')
    $.each(actions || [],function(i,action){
      $action_select.append('<option value="'+action+'">'+action.replace("Controller","")+'</option>')
    })
  })

  $("#themes-select select").change(function(){
    var current_theme = $(this).children("option:selected").eq(0).val();
    var url = $(this).data("url").replace("-theme-",current_theme != "" ? current_theme : "_empty_")
    $.ajax({
      url: url,
      type: "get",
      dataType:"html",
      success:function(html){
        if(html==""){
          $("#content-blocks-container").remove()
        }else{
          var $sibling = $("#content-blocks-container")
          if($sibling){
            $sibling.remove();
          }
          $(html).insertAfter("#themes-select")
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
    var blocks_url = $(this).data("blocks-url").replace("-theme-", theme).replace("-layout-",layout)
    var urls = $(_form_class+" .nested_form:first").clone();
    $.when(
      $.ajax({
        url: blocks_url,
        type: "get",
        dataType: "html",
        success:function(html){
          $("#content-blocks-container #content-blocks").html(html)
        }
      }),
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
            set_layout_form_data(theme,layout,old_title,urls)
          }
          remove_blocks(clones)
        }
      })
    ).then(function(){
      LayoutConfig.init = true
      resize_all_elements();
      initialize_sortables() 
    })
  })

  function rebuild_order_numbers_for($placeholder){
    $placeholder.find("input[id*='order_number']").each(function(index){
      $(this).val(index)
    })  
  }

  // Set theme namd and layout name in form
  function set_layout_form_data(theme,layout,title,urls){
    $("#lolita_layout_theme_name").val(theme)
    $("#lolita_layout_name").val(layout)
    if(title){
      $("#lolita_layout_title").val(title)
    }  
    if(urls){
      $(_form_class + " .nested_form:first").replaceWith(urls)
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
    rebuild_content_block_form_data($block)
    rebuild_order_numbers_for($placeholder)
  }

  function rebuild_content_block_form_data($block,attributes){
    if(attributes){
      for(var attr in attributes){
        var input = $block.children("input[id*='"+attr+"']").eq(0)
        if(input){
          input.val(attributes[attr])
        }
      } 
    }
    if($block.data("content-block-id")){
      $block.children("input[id*='lolita_content_block_id']").eq(0).val($block.data("content-block-id"))
    }else{
      $block.children("input[id*='predefined_block_name']").eq(0).val($block.data("name")) 
    }
  }

  function initialize_sortables(){
    //Placeholders also are sortable but they only changes sortable placeholder look on start and check fitnes of 
    //block in placeholder.
    $(_enabled_ph_class).sortable({
      connectWith: _enabled_ph_class,
      placeholder: "inner-placeholder",
      cursor: "move",
      items: ".content-block",
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
          center_spans($block.children("span:first"))
        }else{
          $(this).sortable("cancel");
          reset_block($block)
        }
      }
    }).disableSelection();
  }
  //Initialize placeholder dimensions
  //initialize_placeholders();
  initialize_sortables();

   //Remove block on double click from placeholders
  $(".content-block.active span.delete").live("click",function(){
    var $block = $(this).parent()
    var clones = collect_removed_elements($block,true)
    var $id = $block.next()
    if($id[0] && $id[0].tagName.toLowerCase()=="input" && $id.attr("id").match(/_id$/)){
      $id.remove()
    }
    var $placeholder = $block.parents(".placeholder").eq(0)
    $block.remove();
    remove_blocks(clones)
    rebuild_order_numbers_for($placeholder)
  })

  $(".content-block.active span.edit").live("click",function(){
    var $block = $(this).parent()
    var $dialog = $("#content-block-form")
    var methods = [$block.data("name")]
    var possible_methods = ($block.attr("data-methods") || "").split(",")
    if(possible_methods[0]!=""){
      var extra_methods = possible_methods
    }else{
      extra_methods = []
    }
    methods = methods.concat(extra_methods)
    $dialog.data("block",$block)
    $dialog.data("methods",methods)
    $dialog.dialog("open")
  })


  var buttons = {}
  buttons[$("#content-block-form").data("button-save")] = function(){
    var $block = $(this).data("block")
    var method_name = $(this).find("select>option:selected").eq(0).val()
    rebuild_content_block_form_data($block,{"data_collection_method": method_name})
    $( this ).dialog( "close" );
  }
  buttons[$("#content-block-form").data("button-cancel")] = function(){
    $( this ).dialog( "close" );
  }
  $("#content-block-form" ).dialog({
      autoOpen: false,
      height: 150,
      width: 300,
      modal: true,
      buttons: buttons,
      open:function(){
        var $select = $(this).find("form select")
        $select.html("")
        $.each($(this).data("methods"),function(index,method_name){
          $select.append("<option value='"+method_name+"'>"+method_name+"</option>")
        })
      },
      close: function() {
        $(this).find("form select").html("")
        //allFields.val( "" ).removeClass( "ui-state-error" );
      }
    });

  //When user press mouse button on contenblock in list it is changed to its real look. 
  // Also some information about original position in list and dimensions are stored.
  $("#content-blocks .content-block").live("mousedown",function(event){
    if(event.which == 1){
      var $new_block = $(this)
      _activated_cb.push(this)
      $new_block.data("domPositionPrev",$new_block.prev()[0] ? true : false)
      $new_block.data("domPositionObj", $new_block.prev()[0] ? $new_block.prev() :  $new_block.parent())
      $new_block.data("old-width",$new_block.data("old-width") || $new_block.width()).data("old-height",$new_block.data("old-height") || $new_block.height())
      $new_block.removeClass("inactive")
      $new_block.addClass("active")
      $new_block.width($new_block.data("width"))
      $new_block.height($new_block.data("height"))
      center_spans($new_block.find("span:first"))
    }
  })

  // When user pressed mouse button and didn't start draging content block it is restored to its previous 
  // look when mouse button is released.
  $("body").live("mouseup",function(){
    while(_activated_cb.length>0){
      var current_cb = _activated_cb.shift()
      if(!$(current_cb).data("started")){
        reset_block($(current_cb)) 
      }
    } 
  })
})