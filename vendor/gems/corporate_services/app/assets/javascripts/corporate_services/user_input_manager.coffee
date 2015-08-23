class @UserInputManager
  constructor : ->
    @user_input_claimant = null
    @undo = null
  claim_user_input_request : (user_input_claimant,undo)->
    console.log "claim with undo method= "+@undo
    if @user_input_claimant
      @terminate_user_input_request()
    @user_input_claimant = user_input_claimant
    @undo = undo
  terminate_user_input_request : ->
    console.log "terminate with undo method= "+@undo
    @user_input_claimant[@undo]()
  reset : ->
    console.log "reset"
    @user_input_claimant = null
    @undo = null

@UserInput = new UserInputManager
