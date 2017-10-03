import Ractive from 'ractive'
import InpageEdit from '../../../../../app/assets/javascripts/in_page_edit.coffee'

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
    start_callback : () => {
      this.set('new_assignee_id',undefined);
      return ractive.expand();
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
