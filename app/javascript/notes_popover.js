import I18n from './notes_popover_translations.js'

export default function(node){
  $(node).popover({
    html : true,
    title() {
      const ractive = new Ractive({
        template : ` <span style= 'z-index:20'>{{ t.details }}</span> `,
        data(){
          return {
            t: I18n.t('notes.note.popover')
          }
        }
      })
      return ractive.toHTML();
    },
    content() {
      const data = Ractive.getNodeInfo(this).ractive.get();
      _.extend(data,{t : I18n.t('notes.note.popover')})
      const ractive = new Ractive({
        template : `
          <table style='width:200px;'>
            <tr><td>{{ t.created_on }}</td><td>{{ date }}</td></tr>
            <tr><td>{{ t.author }}</td><td>{{ author_name }}</td></tr>
            <tr><td>{{ t.updated_on }}</td><td>{{ updated_on }}</td></tr>
            <tr><td>{{ t.updated_by }}</td><td>{{ editor_name }}</td></tr>
          </table>
        `,
        data
      });
      return ractive.toHTML();
    },
    template : `
      <div class='popover fileDetails' role='tooltip'>
        <div class='arrow'/>
        <h3 class='popover-title'/>
        <div class='popover-content'/>
      </div>`,
    trigger: 'hover'
  });
  return {
    teardown() {
      return $(node).off('mouseenter');
    }
  };
};
