log = (str)->
  re = new RegExp('phantomjs','gi')
  unless re.test navigator.userAgent
    console.log str

load_variables = ->
  window.complaints_data = []
  window.all_mandates = []
  window.all_agencies = []
  window.all_agencies_in_threes = _.chain(all_agencies).groupBy((el,i)->Math.floor(i/3)).toArray().value()
  window.complaint_bases = []
  window.next_case_reference = ""
  window.all_users = []
  window.all_categories = []
  window.permitted_filetypes = []
  window.maximum_filesize = 5
  window.filter_criteria = MagicLamp.loadJSON("complaint_filter_criteria")
  window.all_good_governance_complaint_bases = MagicLamp.loadJSON("all_good_governance_complaint_bases")
  window.all_human_rights_complaint_bases = MagicLamp.loadJSON("all_human_rights_complaint_bases")
  window.all_special_investigations_unit_complaint_bases = MagicLamp.loadJSON("all_special_investigations_unit_complaint_bases")
  window.statuses = MagicLamp.loadJSON("statuses")
  window.all_staff = MagicLamp.loadJSON("all_staff")
  MagicLamp.load("complaints_page") # that's the index.haml file being loaded

get_script_under_test = (done)->
  $.getScript("/assets/complaints.js").
    done( ->
      log "(Complaints page) javascript was loaded"
      done()).
    fail( (jqxhr, settings, exception) ->
      log "Triggered ajaxError handler"
      log settings
      log exception)

reset_page = ->
  complaints.set('filter_criteria', window.filter_criteria)
  complaints.set('complaints',[])

describe "complaints index page", ->
  before (done)->
    load_variables()
    get_script_under_test(done)

  after ->
    reset_page()

  it "loads all fixtures", ->
    expect($("h1",'.magic-lamp').text()).to.equal "Complaints"
    #expect($(".complaint", '.magic-lamp').length).to.equal 1 # none pre-loaded
    expect(typeof(simulant)).to.not.equal("undefined")
    return

  describe "match complainant", ->
    it "UI should set the filter criterion value", ->
      $('.filter_control_box #complainant').val("Siddhi")
      simulant.fire($('.filter_control_box #complainant')[0],'change')
      expect(complaints.get('filter_criteria.complainant')).to.equal "Siddhi"

    it "when filter_criteria.complainant is empty", ->
      complaints.set('complaints',[{complainant:"Foo"}])
      complaints.set('filter_criteria.complainant',"")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_complainant()).to.be.true
      expect(complaint.include()).to.be.true
      expect(complaint.get('include')).to.be.true

    it "when filter_criteria.complainant is whitespace", ->
      complaints.set('complaints',[{complainant:"Foo"}])
      complaints.set('filter_criteria.complainant',"  ")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_complainant()).to.be.true
      expect(complaint.include()).to.be.true
      expect(complaint.get('include')).to.be.true

    it "when filter_criteria.complainant has a non-matching value", ->
      complaints.set('complaints',[{complainant:"Foo"}])
      complaints.set('filter_criteria.complainant',"bar")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_complainant()).to.be.false
      expect(complaint.include()).to.be.false
      expect(complaint.get('include')).to.be.false

    it "when filter_criteria.complainant has a matching value", ->
      complaints.set('complaints',[{complainant:"got some foo in my porridge"}])
      complaints.set('filter_criteria.complainant',"Foo")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_complainant()).to.be.true
      expect(complaint.include()).to.be.true
      expect(complaint.get('include')).to.be.true

  describe "match date", ->
    before (done)->
      load_variables()
      get_script_under_test(done)

    after ->
      reset_page()

    it "when from and to are both blank", ->
      complaints.set('complaints',[{date : "2016-08-19T07:00:00+00:00" }])
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_date()).to.be.true
      expect(complaint.include()).to.be.true
      expect(complaint.get('include')).to.be.true

    describe "when from is null", ->
      it "is true when date is less than to date", ->
        complaints.set('complaints',[{date : "2016-08-19T07:00:00+00:00" }])
        complaints.set({'filter_criteria.from':null,'filter_criteria.to':'2016-08-20T07:00:00+00:00'})
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_date()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "is false when date is more than to date", ->
        complaints.set('complaints',[{date : "2016-08-19T07:00:00+00:00" }])
        complaints.set({'filter_criteria.from':null,'filter_criteria.to':'2016-08-16T07:00:00+00:00'})
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_date()).to.be.false
        expect(complaint.include()).to.be.false
        expect(complaint.get('include')).to.be.false

    describe "when from is empty string", ->
      it "is true when date is less than to date", ->
        complaints.set('complaints',[{date : "2016-08-19T07:00:00+00:00" }])
        complaints.set({'filter_criteria.from':'','filter_criteria.to':'2016-08-20T07:00:00+00:00'})
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_date()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "is false when date is more than to date", ->
        complaints.set('complaints',[{date : "2016-08-19T07:00:00+00:00" }])
        complaints.set({'filter_criteria.from':'','filter_criteria.to':'2016-08-16T07:00:00+00:00'})
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_date()).to.be.false
        expect(complaint.include()).to.be.false
        expect(complaint.get('include')).to.be.false

    describe "when to is null", ->
      it "is true when date is more than from date", ->
        complaints.set('complaints',[{date : "2016-08-19T07:00:00+00:00" }])
        complaints.set({'filter_criteria.from':'2016-08-16T07:00:00+00:00','filter_criteria.to':null})
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_date()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "is false when date is less than from date", ->
        complaints.set('complaints',[{date : "2016-08-19T07:00:00+00:00" }])
        complaints.set({'filter_criteria.from':'2016-08-20T07:00:00+00:00','filter_criteria.to':null})
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_date()).to.be.false
        expect(complaint.include()).to.be.false
        expect(complaint.get('include')).to.be.false

    describe "when to is empty string", ->
      it "is true when date is more than from date", ->
        complaints.set('complaints',[{date : "2016-08-19T07:00:00+00:00" }])
        complaints.set({'filter_criteria.from':'2016-08-16T07:00:00+00:00','filter_criteria.to':''})
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_date()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "is false when date is less than from date", ->
        complaints.set('complaints',[{date : "2016-08-19T07:00:00+00:00" }])
        complaints.set({'filter_criteria.from':'2016-08-20T07:00:00+00:00','filter_criteria.to':''})
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_date()).to.be.false
        expect(complaint.include()).to.be.false
        expect(complaint.get('include')).to.be.false

    describe "when to and from are both nonblank", ->
      it "is true when date is equal to from date", ->
        complaints.set('complaints',[{date : "2016-08-16T07:00:00+00:00" }])
        complaints.set({'filter_criteria.from':'2016-08-16T07:00:00+00:00','filter_criteria.to':'2016-08-20T07:00:00+00:00'})
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_date()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "is true when date is equal to to date", ->
        complaints.set('complaints',[{date : "2016-08-20T07:00:00+00:00" }])
        complaints.set({'filter_criteria.from':'2016-08-16T07:00:00+00:00','filter_criteria.to':'2016-08-20T07:00:00+00:00'})
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_date()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "is true when date is between from and to date", ->
        complaints.set('complaints',[{date : "2016-08-19T07:00:00+00:00" }])
        complaints.set({'filter_criteria.from':'2016-08-16T07:00:00+00:00','filter_criteria.to':'2016-08-20T07:00:00+00:00'})
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_date()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "is false when date is less than from date", ->
        complaints.set('complaints',[{date : "2016-08-13T07:00:00+00:00" }])
        complaints.set({'filter_criteria.from':'2016-08-16T07:00:00+00:00','filter_criteria.to':'2016-08-20T07:00:00+00:00'})
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_date()).to.be.false
        expect(complaint.include()).to.be.false
        expect(complaint.get('include')).to.be.false

      it "is false when date is more than to date", ->
        complaints.set('complaints',[{date : "2016-08-21T07:00:00+00:00" }])
        complaints.set({'filter_criteria.from':'2016-08-16T07:00:00+00:00','filter_criteria.to':'2016-08-20T07:00:00+00:00'})
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_date()).to.be.false
        expect(complaint.include()).to.be.false
        expect(complaint.get('include')).to.be.false

  describe "match case reference", ->
    before (done)->
      load_variables()
      get_script_under_test(done)

    after ->
      reset_page()

    it "UI should set the filter criterion value", ->
      $('.filter_control_box #case_reference').val("c88/15")
      simulant.fire($('.filter_control_box #case_reference')[0],'change')
      expect(complaints.get('filter_criteria.case_reference')).to.equal "c88/15"

    it "when filter_criteria.case_reference is empty", ->
      complaints.set('complaints',[{case_reference:"c12/23"}])
      complaints.set('filter_criteria.case_reference',"")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_case_reference()).to.be.true
      expect(complaint.include()).to.be.true
      expect(complaint.get('include')).to.be.true

    it "when filter_criteria.case_reference is whitespace", ->
      complaints.set('complaints',[{case_reference:"c12/23"}])
      complaints.set('filter_criteria.case_reference',"  ")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_case_reference()).to.be.true
      expect(complaint.include()).to.be.true
      expect(complaint.get('include')).to.be.true

    it "when filter_criteria.case_reference has a non-matching value", ->
      complaints.set('complaints',[{case_reference:"c12/23"}])
      complaints.set('filter_criteria.case_reference',"1224")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_case_reference()).to.be.false
      expect(complaint.include()).to.be.false
      expect(complaint.get('include')).to.be.false

    it "when filter_criteria.case_reference has a matching value", ->
      complaints.set('complaints',[{case_reference:"c12/23"}])
      complaints.set('filter_criteria.case_reference',"12/23")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_case_reference()).to.be.true
      expect(complaint.include()).to.be.true
      expect(complaint.get('include')).to.be.true

    it "when filter_criteria.case_reference has an alternative matching value", ->
      complaints.set('complaints',[{case_reference:"c12/23"}])
      complaints.set('filter_criteria.case_reference',"1223")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_case_reference()).to.be.true
      expect(complaint.include()).to.be.true
      expect(complaint.get('include')).to.be.true

  describe "match village", ->
    before (done)->
      load_variables()
      get_script_under_test(done)

    after ->
      reset_page()

    it "UI should set the filter criterion value", ->
      $('.filter_control_box #village').val("Dharamshala")
      simulant.fire($('.filter_control_box #village')[0],'change')
      expect(complaints.get('filter_criteria.village')).to.equal "Dharamshala"

    it "when filter_criteria.village is empty", ->
      complaints.set('complaints',[{village:"Foo"}])
      complaints.set('filter_criteria.village',"")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_village()).to.be.true
      expect(complaint.include()).to.be.true
      expect(complaint.get('include')).to.be.true

    it "when filter_criteria.village is whitespace", ->
      complaints.set('complaints',[{village:"Foo"}])
      complaints.set('filter_criteria.village',"  ")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_village()).to.be.true
      expect(complaint.include()).to.be.true
      expect(complaint.get('include')).to.be.true

    it "when filter_criteria.village has a non-matching value", ->
      complaints.set('complaints',[{village:"Foo"}])
      complaints.set('filter_criteria.village',"bar")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_village()).to.be.false
      expect(complaint.include()).to.be.false
      expect(complaint.get('include')).to.be.false

    it "when filter_criteria.village has a matching value", ->
      complaints.set('complaints',[{village:"got some foo in my porridge"}])
      complaints.set('filter_criteria.village',"Foo")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_village()).to.be.true
      expect(complaint.include()).to.be.true
      expect(complaint.get('include')).to.be.true

  describe "match phone number", ->
    before (done)->
      load_variables()
      get_script_under_test(done)

    after ->
      reset_page()

    it "UI should set the filter criterion value", ->
      $('.filter_control_box #phone').val("555 12212")
      simulant.fire($('.filter_control_box #phone')[0],'change')
      expect(complaints.get('filter_criteria.phone')).to.equal "555 12212"

    it "when filter_criteria.phone is empty", ->
      complaints.set('complaints',[{phone:"(541) 823-7382"}])
      complaints.set('filter_criteria.phone',"")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_phone()).to.be.true
      expect(complaint.include()).to.be.true
      expect(complaint.get('include')).to.be.true

    it "when filter_criteria.phone is whitespace", ->
      complaints.set('complaints',[{phone:"(541) 823-7382"}])
      complaints.set('filter_criteria.phone',"  ")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_phone()).to.be.true
      expect(complaint.include()).to.be.true
      expect(complaint.get('include')).to.be.true

    it "when filter_criteria.phone has a non-matching value", ->
      complaints.set('complaints',[{phone:"(541) 823-7382"}])
      complaints.set('filter_criteria.phone',"824 8833")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_phone()).to.be.false
      expect(complaint.include()).to.be.false
      expect(complaint.get('include')).to.be.false

    it "when filter_criteria.phone has a matching value", ->
      complaints.set('complaints',[{phone:"(541) 823-7382"}])
      complaints.set('filter_criteria.phone',"541)- 823 -7382")
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_phone()).to.be.true
      expect(complaint.include()).to.be.true
      expect(complaint.get('include')).to.be.true

  describe "match basis", ->
    before (done)->
      load_variables()
      get_script_under_test(done)

    after ->
      reset_page()

    describe "when basis_rule is 'all'", ->
      before ->
        complaints.set('filter_criteria.basis_rule','all')

      it "when all filter_criteria.basis_ids are empty", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : []
          'filter_criteria.selected_human_rights_complaint_basis_ids' : []
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : []
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [1,2], human_rights_complaint_basis_ids : [1,2], special_investigations_unit_complaint_basis_ids : [1,2] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when filter_criteria.good_governance_complaint_basis_ids has a non-matching value", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : [1,2]
          'filter_criteria.selected_human_rights_complaint_basis_ids' : []
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : []
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [2], human_rights_complaint_basis_ids : [], special_investigations_unit_complaint_basis_ids : [] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.false
        expect(complaint.include()).to.be.false
        expect(complaint.get('include')).to.be.false

      it "when filter_criteria.good_governance_complaint_basis_ids has a matching value", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : [1,2]
          'filter_criteria.selected_human_rights_complaint_basis_ids' : []
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : []
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [1,2], human_rights_complaint_basis_ids : [], special_investigations_unit_complaint_basis_ids : [] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when filter_criteria.human_rights_complaint_basis_ids has a matching value", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : []
          'filter_criteria.selected_human_rights_complaint_basis_ids' : [1]
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : []
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [], human_rights_complaint_basis_ids : [1], special_investigations_unit_complaint_basis_ids : [] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when filter_criteria.special_investigations_unit_complaint_basis_ids has a matching value", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : []
          'filter_criteria.selected_human_rights_complaint_basis_ids' : []
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : [1]
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [], human_rights_complaint_basis_ids : [], special_investigations_unit_complaint_basis_ids : [1,2] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when there is a mix of matching and non-matching values", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : [1]
          'filter_criteria.selected_human_rights_complaint_basis_ids' : []
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : [1]
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [2], human_rights_complaint_basis_ids : [], special_investigations_unit_complaint_basis_ids : [1] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.false
        expect(complaint.include()).to.be.false
        expect(complaint.get('include')).to.be.false

    describe "when basis_rule is null", ->
      before ->
        complaints.set('filter_criteria.basis_rule',null)

      it "when all filter_criteria.basis_ids are empty", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : []
          'filter_criteria.selected_human_rights_complaint_basis_ids' : []
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : []
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [1,2], human_rights_complaint_basis_ids : [1,2], special_investigations_unit_complaint_basis_ids : [1,2] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when filter_criteria.good_governance_complaint_basis_ids has a non-matching value", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : [1]
          'filter_criteria.selected_human_rights_complaint_basis_ids' : []
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : []
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [2], human_rights_complaint_basis_ids : [], special_investigations_unit_complaint_basis_ids : [] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when filter_criteria.good_governance_complaint_basis_ids has a matching value", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : [1]
          'filter_criteria.selected_human_rights_complaint_basis_ids' : []
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : []
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [1,2], human_rights_complaint_basis_ids : [], special_investigations_unit_complaint_basis_ids : [] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when filter_criteria.human_rights_complaint_basis_ids has a matching value", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : []
          'filter_criteria.selected_human_rights_complaint_basis_ids' : [1]
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : []
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [], human_rights_complaint_basis_ids : [1], special_investigations_unit_complaint_basis_ids : [] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when filter_criteria.special_investigations_unit_complaint_basis_ids has a matching value", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : []
          'filter_criteria.selected_human_rights_complaint_basis_ids' : []
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : [1]
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [], human_rights_complaint_basis_ids : [], special_investigations_unit_complaint_basis_ids : [1] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when there is a mix of matching and non-matching values", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : [1]
          'filter_criteria.selected_human_rights_complaint_basis_ids' : []
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : [1]
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [2], human_rights_complaint_basis_ids : [], special_investigations_unit_complaint_basis_ids : [1] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

    describe "when basis_rule is 'any'", ->
      before ->
        complaints.set('filter_criteria.basis_rule','any')

      it "when all filter_criteria.basis_ids are empty", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : []
          'filter_criteria.selected_human_rights_complaint_basis_ids' : []
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : []
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [1,2], human_rights_complaint_basis_ids : [1,2], special_investigations_unit_complaint_basis_ids : [1,2] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.false
        expect(complaint.include()).to.be.false
        expect(complaint.get('include')).to.be.false

      it "when filter_criteria.good_governance_complaint_basis_ids has a non-matching value", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : [1]
          'filter_criteria.selected_human_rights_complaint_basis_ids' : []
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : []
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [2], human_rights_complaint_basis_ids : [], special_investigations_unit_complaint_basis_ids : [] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.false
        expect(complaint.include()).to.be.false
        expect(complaint.get('include')).to.be.false

      it "when filter_criteria.good_governance_complaint_basis_ids has a matching value", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : [1]
          'filter_criteria.selected_human_rights_complaint_basis_ids' : []
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : []
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [1,2], human_rights_complaint_basis_ids : [], special_investigations_unit_complaint_basis_ids : [] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when filter_criteria.human_rights_complaint_basis_ids has a matching value", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : []
          'filter_criteria.selected_human_rights_complaint_basis_ids' : [1]
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : []
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [], human_rights_complaint_basis_ids : [1], special_investigations_unit_complaint_basis_ids : [] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when filter_criteria.special_investigations_unit_complaint_basis_ids has a matching value", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : []
          'filter_criteria.selected_human_rights_complaint_basis_ids' : []
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : [1]
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [], human_rights_complaint_basis_ids : [], special_investigations_unit_complaint_basis_ids : [1] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when there is a mix of matching and non-matching values", ->
        complaints.set
          'filter_criteria.selected_good_governance_complaint_basis_ids' : [1]
          'filter_criteria.selected_human_rights_complaint_basis_ids' : []
          'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : [1]
        complaints.set('complaints',[{good_governance_complaint_basis_ids : [2], human_rights_complaint_basis_ids : [], special_investigations_unit_complaint_basis_ids : [1] }])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_basis()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

  describe "match agency", ->
    before (done)->
      load_variables()
      get_script_under_test(done)

    after ->
      reset_page()

    describe "when agency filter rule is 'all'", ->
      before ->
        complaints.set('filter_criteria.agency_rule','all')

      it "when filter_criteria.selected_agency_ids is empty", ->
        complaints.set('filter_criteria.selected_agency_ids',[])
        complaints.set('complaints', [{agency_ids : [1,2,3]}])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_agencies()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when complaint has some, but not all values matching selected_agency_ids", ->
        complaints.set('filter_criteria.selected_agency_ids',[1,2])
        complaints.set('complaints', [{agency_ids : [1,2,3]}])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_agencies()).to.be.false
        expect(complaint.include()).to.be.false
        expect(complaint.get('include')).to.be.false

      it "when complaint all agency ids match selected_agency_ids all values", ->
        complaints.set('filter_criteria.selected_agency_ids',[1,2,3])
        complaints.set('complaints', [{agency_ids : [1,2,3]}])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_agencies()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when complaint agency_ids is empty", ->
        complaints.set('filter_criteria.selected_agency_ids',[1,2,3])
        complaints.set('complaints', [{agency_ids : []}])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_agencies()).to.be.false
        expect(complaint.include()).to.be.false
        expect(complaint.get('include')).to.be.false

    describe "when agency filter rule is 'any'", ->
      before ->
        complaints.set('filter_criteria.agency_rule','any')

      it "when filter_criteria.selected_agency_ids is empty", ->
        complaints.set('filter_criteria.selected_agency_ids',[])
        complaints.set('complaints', [{agency_ids : [1,2,3]}])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_agencies()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when complaint has some, but not all values matching selected_agency_ids", ->
        complaints.set('filter_criteria.selected_agency_ids',[1])
        complaints.set('complaints', [{agency_ids : [1,2,3]}])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_agencies()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when complaint all agency ids match selected_agency_ids all values", ->
        complaints.set('filter_criteria.selected_agency_ids',[1,2,3])
        complaints.set('complaints', [{agency_ids : [1,2,3]}])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_agencies()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

      it "when complaint agency_ids is empty", ->
        complaints.set('filter_criteria.selected_agency_ids',[1])
        complaints.set('complaints', [{agency_ids : []}])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_agencies()).to.be.false
        expect(complaint.include()).to.be.false
        expect(complaint.get('include')).to.be.false

    describe "when agency filter rule is not configured", ->
      before ->
        complaints.set('filter_criteria.agency_rule',null)

      it "should declare match anyway", ->
        complaints.set('filter_criteria.selected_agency_ids',[1])
        complaints.set('complaints', [{agency_ids : [1,2,3]}])
        complaint = complaints.findComponent('complaint')
        expect(complaint.matches_agencies()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

  describe "match current assignee", ->
    before (done)->
      load_variables()
      get_script_under_test(done)

    after ->
      reset_page()

    describe "when selected_assignee_id is null", ->
      before ->
        complaints.set('complaints',[{current_assignee_id : 55}])
        complaints.set('filter_criteria.selected_assignee_id',null)

      it "should be included", ->
        complaint = complaints.findAllComponents('complaint')[0]
        expect(complaint.matches_assignee()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

    describe "when selected_assignee_id matches", ->
      before ->
        complaints.set('complaints',[{current_assignee_id : 55}])
        complaints.set('filter_criteria.selected_assignee_id',55)

      it "should be included", ->
        complaint = complaints.findAllComponents('complaint')[0]
        expect(complaint.matches_assignee()).to.be.true
        expect(complaint.include()).to.be.true
        expect(complaint.get('include')).to.be.true

    describe "when selected_assignee_id does not match", ->
      before ->
        complaints.set('complaints',[{current_assignee_id : 44}])
        complaints.set('filter_criteria.selected_assignee_id',55)

      it "should be included", ->
        complaint = complaints.findAllComponents('complaint')[0]
        expect(complaint.matches_assignee()).to.be.false
        expect(complaint.include()).to.be.false
        expect(complaint.get('include')).to.be.false

  describe "match current status", ->
    before (done)->
      load_variables()
      get_script_under_test(done)

    after ->
      reset_page()

    it "should match when status_ids includes the complaint status_id", ->
      complaints.set('filter_criteria.selected_statuses',["Under Evaluation"])
      complaints.set('complaints', [{current_status_humanized : "Under Evaluation"}])
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_status()).to.be.true
      expect(complaint.include()).to.be.true
      expect(complaint.get('include')).to.be.true

    it "should not match when status_ids does not include complaint status_id", ->
      complaints.set('filter_criteria.selected_statuses',["Under Evaluation", "Active"])
      complaints.set('complaints', [{current_status_humanized : "Completed"}])
      complaint = complaints.findComponent('complaint')
      expect(complaint.matches_status()).to.be.false
      expect(complaint.include()).to.be.false
      expect(complaint.get('include')).to.be.false

  describe "reset filter criteria", ->
    before (done)->
      load_variables()
      get_script_under_test(done)

    after ->
      reset_page()

    it "should reset complainant field", ->
      complaints.set('filter_criteria.complainant', "blark")
      $('.fa-refresh').trigger('click')
      expect($('.filter_control_box input#complainant').val()).to.equal ""

    it "should reset village field", ->
      complaints.set('filter_criteria.village', "blark")
      $('.fa-refresh').trigger('click')
      expect($('.filter_control_box input#village').val()).to.equal ""

    it "should reset phone field", ->
      complaints.set('filter_criteria.phone', "blark")
      $('.fa-refresh').trigger('click')
      expect($('.filter_control_box input#phone').val()).to.equal ""

    it "should reset case reference field", ->
      complaints.set('filter_criteria.case_reference', "blark")
      $('.fa-refresh').trigger('click')
      expect($('.filter_control_box input#case_reference').val()).to.equal ""

    it "should reset from date field", ->
      complaints.set('filter_criteria.from', "02/03/2016")
      $('.fa-refresh').trigger('click')
      expect($('.filter_control_box input#from').val()).to.equal ""

    it "should reset to date field", ->
      complaints.set('filter_criteria.to', "02/03/2016")
      $('.fa-refresh').trigger('click')
      expect($('.filter_control_box input#to').val()).to.equal ""

    it "should reset complaint basis selection", ->
      complaint_basis_ids = _(complaints.get('all_good_governance_complaint_bases')).pluck('id')
      complaints.set('filter_criteria.selected_good_governance_complaint_basis_ids',complaint_basis_ids)
      complaints.set('filter_criteria.basis_rule','any')
      $('.fa-refresh').trigger('click')
      expect(complaints.get('filter_criteria.selected_good_governance_complaint_basis_ids')).to.be.empty
      expect(complaints.get('filter_criteria.basis_rule')).to.be.null

    it "should reset agency selection", ->
      agency_ids = _(complaints.get('all_agencies')).pluck('id')
      complaints.set('filter_criteria.selected_agency_ids',agency_ids)
      complaints.set('filter_criteria.agency_rule','any')
      $('.fa-refresh').trigger('click')
      expect(complaints.get('filter_criteria.selected_agency_ids')).to.be.empty
      expect(complaints.get('filter_criteria.agency_rule')).to.be.null

    it "should reset assignee selection", ->
      staff_id = _(complaints.get('all_staff')).pluck('id')[0]
      complaints.set('filter_criteria.selected_assignee_id', staff_id)
      $('.fa-refresh').trigger('click')
      expect(complaints.get('filter_criteria.selected_assignee_id')).to.be.blank

  describe "render included complaints", ->
    before (done)->
      load_variables()
      window.complaints_data = MagicLamp.loadJSON('complaints_data')
      get_script_under_test(done)

    after ->
      reset_page()

    it "should render all complaints by default", ->
      expect($('#complaints .complaint').length).to.equal 4

    it "should show complaints matching complainant", ->
      complaints.set('filter_criteria.complainant', "Cam")
      expect($('#complaints .complaint:visible').length).to.equal 1
      complaints.set('filter_criteria.complainant', "")
      expect($('#complaints .complaint:visible').length).to.equal 4
      complaints.set('filter_criteria.complainant', "Cam")
      expect($('#complaints .complaint:visible').length).to.equal 1
      $('.fa-refresh').trigger('click')
      expect($('#complaints .complaint:visible').length).to.equal 4

    it "should show complaints matching village", ->
      complaints.set('filter_criteria.village', " por")
      expect($('#complaints .complaint:visible').length).to.equal 1
      complaints.set('filter_criteria.village', "")
      expect($('#complaints .complaint:visible').length).to.equal 4
      complaints.set('filter_criteria.village', " por")
      $('.fa-refresh').trigger('click')
      expect($('#complaints .complaint:visible').length).to.equal 4

    it "should show complaints matching phone", ->
      complaints.set('filter_criteria.phone', "567")
      expect($('#complaints .complaint:visible').length).to.equal 1
      complaints.set('filter_criteria.phone', "")
      expect($('#complaints .complaint:visible').length).to.equal 4
      complaints.set('filter_criteria.phone', "567")
      $('.fa-refresh').trigger('click')
      expect($('#complaints .complaint:visible').length).to.equal 4

    it "should show complaints matching case_reference", ->
      complaints.set('filter_criteria.case_reference', "34")
      expect($('#complaints .complaint:visible').length).to.equal 1
      complaints.set('filter_criteria.case_reference', "")
      expect($('#complaints .complaint:visible').length).to.equal 4
      complaints.set('filter_criteria.case_reference', "34")
      $('.fa-refresh').trigger('click')
      expect($('#complaints .complaint:visible').length).to.equal 4

    it "should show complaints matching status", ->
      complaints.set('filter_criteria.selected_statuses',["Active", "Completed"])
      expect($('#complaints .complaint:visible').length).to.equal 4

      complaints.set('filter_criteria.selected_statuses',["Completed"])
      expect($('#complaints .complaint:visible').length).to.equal 2

      complaints.set('filter_criteria.selected_statuses',["Active"])
      expect($('#complaints .complaint:visible').length).to.equal 2

      $('.fa-refresh').trigger('click')
      expect($('#complaints .complaint:visible').length).to.equal 4

    it "should show complaints matching since date", ->
      complaints.set({'filter_criteria.from':'2016-08-16T07:00:00+00:00','filter_criteria.to':null})
      expect($('#complaints .complaint:visible').length).to.equal 1
      complaints.set({'filter_criteria.from':null,'filter_criteria.to':null})
      expect($('#complaints .complaint:visible').length).to.equal 4
      complaints.set({'filter_criteria.from':'2016-08-16T07:00:00+00:00','filter_criteria.to':null})
      $('.fa-refresh').trigger('click')
      expect($('#complaints .complaint:visible').length).to.equal 4

    it "should show complaints matching until date", ->
      complaints.set({'filter_criteria.from':null,'filter_criteria.to':'2016-08-16T07:00:00+00:00'})
      expect($('#complaints .complaint:visible').length).to.equal 3
      complaints.set({'filter_criteria.from':null,'filter_criteria.to':null})
      expect($('#complaints .complaint:visible').length).to.equal 4
      complaints.set({'filter_criteria.from':null,'filter_criteria.to':'2016-08-16T07:00:00+00:00'})
      $('.fa-refresh').trigger('click')
      expect($('#complaints .complaint:visible').length).to.equal 4

    it "should show complaints matching complaint basis", ->
      complaints.set('filter_criteria.basis_rule','all')
      complaints.set
        'filter_criteria.selected_good_governance_complaint_basis_ids' : [1,2]
        'filter_criteria.selected_human_rights_complaint_basis_ids' : []
        'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : []
      expect($('#complaints .complaint:visible').length).to.equal 1
      complaints.set
        'filter_criteria.selected_good_governance_complaint_basis_ids' : []
        'filter_criteria.selected_human_rights_complaint_basis_ids' : []
        'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : []
      expect($('#complaints .complaint:visible').length).to.equal 4
      complaints.set
        'filter_criteria.selected_good_governance_complaint_basis_ids' : [1,2]
        'filter_criteria.selected_human_rights_complaint_basis_ids' : []
        'filter_criteria.selected_special_investigations_unit_complaint_basis_ids' : []
      $('.fa-refresh').trigger('click')
      expect($('#complaints .complaint:visible').length).to.equal 4

    it "should show complaints matching agency", ->
      complaints.set('filter_criteria.agency_rule','all')
      complaints.set('filter_criteria.selected_agency_ids', [1])
      expect($('#complaints .complaint:visible').length).to.equal 1
      complaints.set('filter_criteria.agency_rule',null)
      complaints.set('filter_criteria.selected_agency_ids', [])
      expect($('#complaints .complaint:visible').length).to.equal 4
      complaints.set('filter_criteria.agency_rule','all')
      complaints.set('filter_criteria.selected_agency_ids', [1])
      expect($('#complaints .complaint:visible').length).to.equal 1
      $('.fa-refresh').trigger('click')
      expect($('#complaints .complaint:visible').length).to.equal 4

    it "should show complaints matching assignee", ->
      complaints.set('filter_criteria.selected_assignee_id',null)
      expect($('#complaints .complaint:visible').length).to.equal 4
      complaints.set('filter_criteria.selected_assignee_id',1)
      expect($('#complaints .complaint:visible').length).to.equal 1
      complaints.set('filter_criteria.selected_assignee_id',null)
      expect($('#complaints .complaint:visible').length).to.equal 4
      complaints.set('filter_criteria.selected_assignee_id',1)
      $('.fa-refresh').trigger('click')
      expect($('#complaints .complaint:visible').length).to.equal 4

  describe "complaint validation", ->
    before (done)->
      load_variables()
      get_script_under_test(done)

    after ->
      reset_page()

    it "should validate a well-formed complaint, excluding assignee when editing", ->
      complaints.set('complaints',[{ complainant:"Foo", village:"Bar", mandate_name : "Good Governance",complaint_basis_ids:[2]}])
      complaints.findAllComponents('complaint')[0].set('editing',true)
      expect(complaints.findAllComponents('complaint')[0].validate()).to.equal true

    it "should validate a well-formed complaint, including assignee when not editing", ->
      complaints.set('complaints',[{complainant:"Foo", village:"Bar", mandate_name : "Good Governance",complaint_basis_ids:[2]}])
      complaints.findAllComponents('complaint')[0].set('new_assignee_id', 8)
      expect(complaints.findAllComponents('complaint')[0].validate()).to.equal true

    it "should validate a complaint with no complainant if it is imported", ->
      complaints.set('complaints',[{ village : "Bar", mandate_name : "Good Governance", complaint_basis_ids:[2], new_assignee_id:8, imported:true}])
      expect(complaints.findAllComponents('complaint')[0].validate()).to.equal true

    it "should validate a complaint with no village if it is imported", ->
      complaints.set('complaints',[{ complainant : "Foo", mandate_name : "Good Governance", complaint_basis_ids:[2], new_assignee_id:8, imported:true}])
      expect(complaints.findAllComponents('complaint')[0].validate()).to.equal true

    it "should not validate a complaint with no complainant if it is not imported", ->
      complaints.set('complaints',[{ village : "Bar", mandate_name : "Good Governance", complaint_basis_ids:[2], new_assignee_id:8, imported:false}])
      expect(complaints.findAllComponents('complaint')[0].validate()).to.equal false

    it "should not validate a complaint with no village if it is not imported", ->
      complaints.set('complaints',[{ complainant : "Foo", mandate_name : "Good Governance", complaint_basis_ids:[2], new_assignee_id:8, imported:false}])
      expect(complaints.findAllComponents('complaint')[0].validate()).to.equal false

    it "should validate an imported complaint missing village, excluding assignee when editing", ->
      complaints.set('complaints',[{ complainant:"Foo", mandate_name : "Good Governance", complaint_basis_ids:[2], imported:true}])
      complaints.findAllComponents('complaint')[0].set('editing',true)
      expect(complaints.findAllComponents('complaint')[0].validate()).to.equal true

    it "should validate an imported complaint missing complaint_basis_ids, including assignee when not editing", ->
      complaints.set('complaints',[{complainant:"Foo", village:"Bar", mandate_name : "Good Governance", complaint_basis_ids:[], imported:true}])
      complaints.findAllComponents('complaint')[0].set('new_assignee_id', 8)
      expect(complaints.findAllComponents('complaint')[0].validate()).to.equal true

    it "should validate a complaint missing complaint_basis_ids, excluding assignee when editing, when not imported", ->
      complaints.set('complaints',[{ complainant:"Foo", village:"Bar", mandate_name : "Good Governance" ,complaint_basis_ids:[], imported:false}])
      complaints.findAllComponents('complaint')[0].set('good_governance_complaint_basis_ids', [])
      complaints.findAllComponents('complaint')[0].set('special_investigations_unit_complaint_basis_ids', [])
      complaints.findAllComponents('complaint')[0].set('human_rights_complaint_basis_ids', [])
      complaints.findAllComponents('complaint')[0].set('editing',true)
      expect(complaints.findAllComponents('complaint')[0].validate()).to.equal false

    it "should validate a complaint missing complaint_basis_ids, including assignee when not editing, when not imported", ->
      complaints.set('complaints',[{complainant:"Foo", village:"Bar", mandate_name : "Good Governance", good_governance_complaint_basis_ids: [], special_investigations_unit_complaint_basis_ids: [], human_rights_complaint_basis_ids: [], imported:true}])
      complaints.findAllComponents('complaint')[0].set('good_governance_complaint_basis_ids', [])
      complaints.findAllComponents('complaint')[0].set('special_investigations_unit_complaint_basis_ids', [])
      complaints.findAllComponents('complaint')[0].set('human_rights_complaint_basis_ids', [])
      complaints.findAllComponents('complaint')[0].set('new_assignee_id', 8)
      expect(complaints.findAllComponents('complaint')[0].validate()).to.equal true

    it "should validate a complaint missing complaint_basis_ids, excluding assignee when editing, when imported", ->
      complaints.set('complaints',[{ complainant:"Foo", village:"Bar", mandate_name:"Good Governance", imported:true}])
      complaints.findAllComponents('complaint')[0].set('good_governance_complaint_basis_ids', [])
      complaints.findAllComponents('complaint')[0].set('special_investigations_unit_complaint_basis_ids', [])
      complaints.findAllComponents('complaint')[0].set('human_rights_complaint_basis_ids', [])
      complaints.findAllComponents('complaint')[0].set('editing',true)
      expect(complaints.findAllComponents('complaint')[0].validate()).to.equal true

    it "should validate a complaint missing complaint_basis_ids, including assignee when not editing, when imported", ->
      complaints.set('complaints',[{complainant:"Foo", village:"Bar", mandate_ids:[8],complaint_basis_ids:[], imported:false}])
      complaints.findAllComponents('complaint')[0].set('good_governance_complaint_basis_ids', [])
      complaints.findAllComponents('complaint')[0].set('special_investigations_unit_complaint_basis_ids', [])
      complaints.findAllComponents('complaint')[0].set('human_rights_complaint_basis_ids', [])
      complaints.findAllComponents('complaint')[0].set('new_assignee_id', 8)
      expect(complaints.findAllComponents('complaint')[0].validate()).to.equal false

  describe "communication validation", ->
    before (done)->
      load_variables()
      get_script_under_test(done)

    after ->
      reset_page()

    it "should not be valid with null user_id", ->
      window.communications.set('communications',[{id:1,user_id:null,mode:'email',direction:'sent'}])
      expect(communications.findAllComponents('communication')[0].validate()).to.be.false
      expect(communications.findAllComponents('communication')[0].get('user_id_error')).to.be.true

    it "should not be valid with blank user_id", ->
      window.communications.set('communications',[{id:1,user_id:"",mode:'email',direction:'sent'}])
      expect(communications.findAllComponents('communication')[0].validate()).to.be.false
      expect(communications.findAllComponents('communication')[0].get('user_id_error')).to.be.true

    it "should be valid with numeric user_id", ->
      window.communications.set('communications',[{id:1,user_id:5,mode:'email',direction:'sent'}])
      expect(communications.findAllComponents('communication')[0].validate()).to.be.true
      expect(communications.findAllComponents('communication')[0].get('user_id_error')).to.be.false

    it "should be valid with numeric string user_id", ->
      window.communications.set('communications',[{id:1,user_id:"5",mode:'email',direction:'sent'}])
      expect(communications.findAllComponents('communication')[0].validate()).to.be.true
      expect(communications.findAllComponents('communication')[0].get('user_id_error')).to.be.false

    it "should not be valid with null mode", ->
      window.communications.set('communications',[{id:1,user_id:5,mode:null,direction:'sent'}])
      expect(communications.findAllComponents('communication')[0].validate()).to.be.false
      expect(communications.findAllComponents('communication')[0].get('mode_error')).to.be.true

    it "should not be valid with blank mode", ->
      window.communications.set('communications',[{id:1,user_id:5,mode:"",direction:'sent'}])
      expect(communications.findAllComponents('communication')[0].validate()).to.be.false
      expect(communications.findAllComponents('communication')[0].get('mode_error')).to.be.true

    it "should be valid with valid string mode", ->
      window.communications.set('communications',[{id:1,user_id:5,mode:'email',direction:'sent'}])
      expect(communications.findAllComponents('communication')[0].validate()).to.be.true
      expect(communications.findAllComponents('communication')[0].get('mode_error')).to.be.false

    it "should not be valid with invalid string mode", ->
      window.communications.set('communications',[{id:1,user_id:5,mode:"foo",direction:'sent'}])
      expect(communications.findAllComponents('communication')[0].validate()).to.be.false
      expect(communications.findAllComponents('communication')[0].get('mode_error')).to.be.true

    describe "validation of direction with a custom function", ->
      it "should not validate if mode is phone and direction is not provided", ->
        window.communications.set('communications',[{id:1,user_id:5,mode:"phone"}])
        expect(communications.findAllComponents('communication')[0].validate()).to.be.false
        expect(communications.findAllComponents('communication')[0].get('direction_error')).to.be.true

      it "should validate if mode is phone and direction is provided", ->
        window.communications.set('communications',[{id:1,user_id:5,mode:"phone",direction:"sent"}])
        expect(communications.findAllComponents('communication')[0].validate()).to.be.true
        expect(communications.findAllComponents('communication')[0].get('direction_error')).to.be.false

      it "should validate if mode is face to face and direction is not provided", ->
        window.communications.set('communications',[{id:1,user_id:5,mode:"face to face"}])
        expect(communications.findAllComponents('communication')[0].validate()).to.be.true
        expect(communications.findAllComponents('communication')[0].get('direction_error')).to.be.false
