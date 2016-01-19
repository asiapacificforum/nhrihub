(function() {
  $(function() {
    var Activity, EditInPlace, Outcome, PerformanceIndicator, PlannedResult, StrategicPriority;
    Ractive.DEBUG = false;
    PerformanceIndicator = Ractive.extend({
      template: '#performance_indicator_template',
      computed: {
        persisted: function() {
          return !isNaN(parseInt(this.get('id')));
        }
      },
      remove_description_errors: function() {
        return this.set("description_error", "");
      },
      create_save: function() {
        var context, data, url;
        context = $(this.find('.new_performance_indicator'));
        url = this.parent.get('create_performance_indicator_url');
        data = context.find(':input').serializeArray();
        data.push({
          name: 'performance_indicator[activity_id]',
          value: this.get('activity_id')
        });
        if (this.validate()) {
          return $.ajax({
            type: 'post',
            url: url,
            data: data,
            dataType: 'json',
            success: this.create_performance_indicator,
            context: this
          });
        }
      },
      validate: function() {
        this.set('description', this.get('description').trim());
        if (this.get('description') === "") {
          this.set("description_error", true);
          return false;
        } else {
          return true;
        }
      },
      create_performance_indicator: function(response, statusText, jqxhr) {
        UserInput.reset();
        return this.parent.set('performance_indicators', response);
      },
      delete_this: function(event, object) {
        var data, ev;
        ev = $.Event(event);
        ev.stopPropagation();
        data = [
          {
            name: '_method',
            value: 'delete'
          }
        ];
        return $.ajax({
          url: this.get('url'),
          data: data,
          method: 'post',
          dataType: 'json',
          context: this,
          success: this.update_performance_indicator
        });
      },
      update_performance_indicator: function(resp, statusText, jqxhr) {
        UserInput.reset();
        return this.parent.set(resp);
      },
      remove_errors: function() {
        return this.remove_description_errors();
      },
      show_reminders_panel: function() {
        return $('#reminders_modal').modal('show');
      },
      show_notes_panel: function() {
        return $('#notes_modal').modal('show');
      },
      show_rules_panel: function() {
        return $('#rules_modal').modal('show');
      },
      create_stop: function() {
        UserInput.reset();
        return this.parent.remove_performance_indicator_form();
      }
    });
    Activity = Ractive.extend({
      template: '#activity_template',
      components: {
        pi: PerformanceIndicator
      },
      computed: {
        persisted: function() {
          return !isNaN(parseInt(this.get('id')));
        }
      },
      create_stop: function() {
        UserInput.reset();
        return this.parent.remove_activity_form();
      },
      create_save: function() {
        var context, data, url;
        context = $(this.el);
        url = this.parent.get('create_activity_url');
        data = context.find('.row.new_activity :input').serializeArray();
        data.push({
          name: 'activity[outcome_id]',
          value: this.get('outcome_id')
        });
        if (this.validate()) {
          return $.ajax({
            type: 'post',
            url: url,
            data: data,
            dataType: 'json',
            success: this.create_activity,
            context: this
          });
        }
      },
      validate: function() {
        this.set('description', this.get('description').trim());
        if (this.get('description') === "") {
          this.set("description_error", true);
          return false;
        } else {
          return true;
        }
      },
      create_activity: function(response, statusText, jqxhr) {
        UserInput.reset();
        return this.parent.set('activities', response);
      },
      delete_this: function(event, object) {
        var data, ev;
        ev = $.Event(event);
        ev.stopPropagation();
        data = [
          {
            name: '_method',
            value: 'delete'
          }
        ];
        return $.ajax({
          url: this.get('url'),
          data: data,
          method: 'post',
          dataType: 'json',
          context: this,
          success: this.update_activity
        });
      },
      update_activity: function(resp, statusText, jqxhr) {
        UserInput.reset();
        return this.parent.set(resp);
      },
      remove_errors: function() {
        return this.remove_description_errors();
      },
      remove_description_errors: function() {
        return this.set("description_error", "");
      },
      new_performance_indicator: function() {
        this.push('performance_indicators', {
          description: '',
          indexed_description: '',
          target: '',
          id: null,
          activity_id: this.get('id'),
          url: null,
          description_error: "",
          progress: ""
        });
        return UserInput.claim_user_input_request(this, 'remove_performance_indicator_form');
      },
      remove_performance_indicator_form: function() {
        if (_.isNull(this.findAllComponents('pi')[this.get('performance_indicators').length - 1].get('id'))) {
          return this.pop('performance_indicators');
        }
      }
    });
    Outcome = Ractive.extend({
      template: '#outcome_template',
      computed: {
        persisted: function() {
          return !isNaN(parseInt(this.get('id')));
        }
      },
      components: {
        activity: Activity
      },
      create_stop: function() {
        UserInput.reset();
        return this.parent.remove_outcome_form();
      },
      create_save: function() {
        var context, data, url;
        context = $(this.el);
        url = this.parent.get('create_outcome_url');
        data = context.find('.row#new_outcome :input').serializeArray();
        data.push({
          name: 'outcome[planned_result_id]',
          value: this.get('planned_result_id')
        });
        if (this.validate()) {
          return $.ajax({
            type: 'post',
            url: url,
            data: data,
            dataType: 'json',
            success: this.create_outcome,
            context: this
          });
        }
      },
      validate: function() {
        this.set('description', this.get('description').trim());
        if (this.get('description') === "") {
          this.set("description_error", true);
          return false;
        } else {
          return true;
        }
      },
      create_outcome: function(response, statusText, jqxhr) {
        UserInput.reset();
        this.parent.set('outcomes', response);
        return this.parent.show_add_outcome();
      },
      remove_description_errors: function() {
        return this.set("description_error", "");
      },
      remove_errors: function() {
        return this.remove_description_errors();
      },
      delete_this: function(event, object) {
        var data, ev;
        ev = $.Event(event);
        ev.stopPropagation();
        data = [
          {
            name: '_method',
            value: 'delete'
          }
        ];
        return $.ajax({
          url: this.get('url'),
          data: data,
          method: 'post',
          dataType: 'json',
          context: this,
          success: this.update_pr
        });
      },
      update_pr: function(resp, statusText, jqxhr) {
        UserInput.reset();
        return this.parent.set(resp);
      },
      new_activity: function() {
        this.push('activities', {
          description: '',
          indexed_description: '',
          id: null,
          outcome_id: this.get('id'),
          url: null,
          description_error: ""
        });
        return UserInput.claim_user_input_request(this, 'remove_activity_form');
      },
      remove_activity_form: function() {
        if (_.isNull(this.findAllComponents('activity')[this.get('activities').length - 1].get('id'))) {
          return this.pop('activities');
        }
      }
    });
    PlannedResult = Ractive.extend({
      template: '#planned_result_template',
      computed: {
        persisted: function() {
          return !isNaN(parseInt(this.get('id')));
        }
      },
      components: {
        outcome: Outcome
      },
      oninit: function() {
        if (!this.get('persisted')) {
          return this.parent.hide_add_planned_result();
        }
      },
      create_stop: function() {
        UserInput.reset();
        return this.parent.remove_planned_result_form();
      },
      create_save: function() {
        var context, data, url;
        context = $(this.el);
        url = this.parent.get('create_planned_result_url');
        data = context.find('.new_planned_result :input').serializeArray();
        data.push({
          name: 'planned_result[strategic_priority_id]',
          value: this.get('strategic_priority_id')
        });
        if (this.validate(data)) {
          return $.ajax({
            type: 'post',
            url: url,
            data: data,
            dataType: 'json',
            success: this.create_pr,
            context: this
          });
        }
      },
      validate: function() {
        this.set('description', this.get('description').trim());
        if (this.get('description') === "") {
          this.set("description_error", true);
          return false;
        } else {
          return true;
        }
      },
      remove_description_errors: function() {
        return this.set("description_error", false);
      },
      remove_errors: function() {
        return this.remove_description_errors();
      },
      create_pr: function(response, statusText, jqxhr) {
        UserInput.reset();
        this.parent.set('planned_results', response);
        return this.parent.show_add_planned_result();
      },
      delete_this: function(event) {
        var data, ev;
        ev = $.Event(event);
        ev.stopPropagation();
        data = [
          {
            name: 'id',
            value: this.get('id')
          }, {
            name: '_method',
            value: 'delete'
          }
        ];
        return $.ajax({
          url: this.get('url'),
          data: data,
          method: 'post',
          dataType: 'json',
          context: this,
          success: this.update_all_pr
        });
      },
      update_pr: function(response, statusText, jqxhr) {
        return this.set(response);
      },
      update_all_pr: function(response, statusText, jqxhr) {
        UserInput.reset();
        return this.parent.set('planned_results', response);
      },
      new_outcome: function() {
        UserInput.claim_user_input_request(this, 'remove_outcome_form');
        this.push('outcomes', {
          description: '',
          indexed_description: '',
          id: null,
          planned_result_id: this.get('id'),
          url: null,
          description_error: ""
        });
        return this.hide_add_outcome();
      },
      remove_outcome_form: function() {
        if (_.isNull(this.findAllComponents('outcome')[this.get('outcomes').length - 1].get('id'))) {
          this.pop('outcomes');
        }
        return this.show_add_outcome();
      },
      _add_outcome: function() {
        return $(this.parent.el).find('.new_outcome').closest('.row');
      },
      hide_add_outcome: function() {
        return this._add_outcome().hide();
      },
      show_add_outcome: function() {
        return this._add_outcome().show();
      }
    });
    EditInPlace = function(node, id) {
      var ractive;
      ractive = this;
      this.edit = new InpageEdit({
        on: node,
        object: this,
        focus_element: 'input.title',
        success: function(response, textStatus, jqXhr) {
          ractive = this.options.object;
          strategic_plan.set('strategic_priorities', response);
          return this.load();
        },
        error: function() {
          return console.log("Changes were not saved, for some reason");
        }
      });
      return {
        teardown: function(id) {},
        update: function(id) {
          if (_.isUndefined(id)) {

          } else {

          }
        }
      };
    };
    Ractive.decorators.inpage_edit = EditInPlace;
    StrategicPriority = Ractive.extend({
      onconfig: function() {
        this.set('original_description', this.get('description'));
        return this.set('original_priority_level', this.get('priority_level'));
      },
      template: '#strategic_priority_template',
      components: {
        pr: PlannedResult
      },
      computed: {
        length: function() {
          if (this.get('description')) {
            return this.get('description').length;
          } else {
            return 0;
          }
        },
        count: function() {
          return Math.max(0, 100 - this.get('length'));
        },
        spid: function() {
          return window.strategic_plan.get('id');
        },
        persisted: function() {
          return !isNaN(parseInt(this.get('id')));
        }
      },
      new_planned_result: function() {
        UserInput.claim_user_input_request(this, 'remove_planned_result_form');
        return this.push('planned_results', {
          id: null,
          description: "",
          strategic_priority_id: this.get('id'),
          description_error: "",
          outcomes: []
        });
      },
      cancel: function() {
        UserInput.reset();
        return this.parent.get('strategic_priorities').shift();
      },
      form: function() {
        return $(this.nodes.new_strategic_priority);
      },
      save: function() {
        var data, url;
        data = this.form().serializeArray();
        url = this.form().attr('action');
        if (this.validate(data)) {
          return $.post(url, data, this.update_sp, 'json');
        }
      },
      update_sp: function(data, textStatus, jqxhr) {
        UserInput.reset();
        return strategic_plan.set('strategic_priorities', data);
      },
      "delete": function() {
        var data;
        data = {
          '_method': 'delete'
        };
        return $.post(this.get('url'), data, this.update_sp, 'json');
      },
      validate: function() {
        var desc, pl;
        pl = this._validate('priority_level');
        desc = this._validate('description');
        return pl && desc;
      },
      _validate: function(field) {
        var value;
        if (_.isString(this.get(field))) {
          this.set(field, this.get(field).trim());
        }
        value = this.get(field);
        if (value === "" || _.isNull(value)) {
          this.set(field + "_error", true);
          return false;
        } else {
          return true;
        }
      },
      remove_priority_level_errors: function() {
        return this.set("priority_level_error", false);
      },
      remove_description_errors: function() {
        return this.set("description_error", false);
      },
      remove_errors: function() {
        return this.remove_priority_level_errors() && this.remove_description_errors();
      },
      _add_planned_result: function() {
        return $(this.parent.el).find('.new_planned_result').closest('.row');
      },
      hide_add_planned_result: function() {
        return this._add_planned_result().hide();
      },
      show_add_planned_result: function() {
        return this._add_planned_result().show();
      },
      remove_planned_result_form: function() {
        if (_.isNull(this.findAllComponents('pr')[this.get('planned_results').length - 1].get('id'))) {
          this.pop('planned_results');
        }
        return this.show_add_planned_result();
      }
    });
    return window.strategic_plan = new Ractive({
      el: "#strategic_plan",
      template: "#strategic_plan_template",
      data: strategic_plan_data,
      components: {
        sp: StrategicPriority
      },
      new_strategic_priority: function() {
        UserInput.claim_user_input_request(this, 'remove_strategic_priorities_form');
        if (this.findAllComponents().length === 0 || this.findComponent().get('persisted')) {
          return strategic_plan.unshift('strategic_priorities', {
            id: null,
            description: '',
            priority_level: null
          });
        }
      },
      remove_strategic_priorities_form: function() {
        return this.get('strategic_priorities').shift();
      }
    });
  });

}).call(this);
