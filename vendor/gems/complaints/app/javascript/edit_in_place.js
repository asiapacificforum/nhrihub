const EditInPlace = function(node,id){
  const ractive = this;
  const edit = new InpageEdit({
    object : this,
    on : node,
    focus_element : 'input.title',
    success(response, textStatus, jqXhr){
      this.options.object.set(response);
      return this.load();
    },
    error() {
      return console.log("Changes were not saved, for some reason");
    },
    before_edit_start : () => {
      ractive.expand();
    },
    start_callback : () => {
      this.set('new_assignee_id',undefined);
    }
  });
  return {
    teardown : id=> {
      return edit.off();
    },
    update : id=> {}
    };
};

Ractive.decorators.inpage_edit = EditInPlace;
