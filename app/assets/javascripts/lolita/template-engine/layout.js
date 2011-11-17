
$(function(){
  var _activated_cb = [];
  var $blocks_source = $("#content-blocks");
  var _enabled_ph_class = ".placeholder.enabled"
  var _all_ph_class = ".placeholder"
  var _disabled_ph_class = ".placeholder.disabled"
  

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
 
  function reset_block($block){
    $block.removeClass("active");
    $block.addClass("inactive")
    $block.height($block.data("old-height"));
    $block.width($block.data("old-width"))
    return $block
  }

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
  function fix_real_placeholder(ui){
    $block = ui.item
    $real_ph = $(".inner-placeholder")
    $real_ph.width($block.width());
    $real_ph.height($block.height());  
    $real_ph.css("cssFloat","left")
  }

  $(_all_ph_class).each(function(){
    $(this).css("width",$(this).data("width")+"px")
    $(this).css("min-height",($(this).data("height")+"px"))
  })

  $(".content-block.active").live("dblclick",function(){
    $(this).remove();
  })

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

  $blocks_source.sortable({
    connectWith: _enabled_ph_class,
    placeholder: 'inner-placeholder',
    cursor: "move",
    items: ".content-block",
    start:function(event,ui){
      ui.item.data("started",true)
      fix_real_placeholder(ui)
    },
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

 
  $("#content-blocks .content-block").mousedown(function(){
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
  $("body").mouseup(function(){
    while(_activated_cb.length>0){
      var current_cb = _activated_cb.shift()
      if(!$(current_cb).data("started")){
        reset_block($(current_cb)) 
      }
    } 
  })
})