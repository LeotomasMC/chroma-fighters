package inputManager.controllers;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import inputManager.GenericInput;
import inputManager.InputEnums;
import inputManager.InputHelper;
import inputManager.InputTypes;

class GenericController extends GenericInput {
   /**
      the raw flixel gamepad associated with this input handler
   **/
   public var _flixelGamepad(default, set):FlxGamepad;

   override public function get_inputType() {
      return "Controller (Generic)";
   }

   override public function get_inputEnabled() {
      if (this._flixelGamepad.connected != true) {
         // Main.log('controller connected: ${this._flixelGamepad.connected}');
         return false;
      }

      return true;
   }

   public function new(slot:PlayerSlotIdentifier, ?profile:String) {
      super(slot, profile);
   }

   function set__flixelGamepad(newInput:FlxGamepad):FlxGamepad {
      this._flixelGamepad = newInput;
      this.handleNewInput();
      return newInput;
   }

   private function handleNewInput() {}

   @:access(flixel.input.gamepad.FlxGamepad)
   public function getFromFlixelGamepadButton(button:FlxGamepadInputID):INPUT_STATE {
      if (!this._flixelGamepad.connected)
         return NOT_PRESSED;
      return InputHelper.getFromFlxInput(this._flixelGamepad.getButton(this._flixelGamepad.mapping.getRawID(button)));
   }

   public function getAxisValue(axis:GenericAxis):Float {
      return switch (axis) {
         case LEFT_STICK_X:
            this._flixelGamepad.analog.value.LEFT_STICK_X;
         default: 0.0;
      }
   }

   public function getButtonState(button:GenericButton):INPUT_STATE {
      return switch (button) {
         case NULL:
            NOT_PRESSED;
         case TRUE:
            if (!this._flixelGamepad.connected) NOT_PRESSED; else PRESSED;
         case FACE_A:
            this.getFromFlixelGamepadButton(A);
         case FACE_B:
            this.getFromFlixelGamepadButton(B);
         case FACE_X:
            this.getFromFlixelGamepadButton(X);
         case FACE_Y:
            this.getFromFlixelGamepadButton(Y);
         case DPAD_UP:
            this.getFromFlixelGamepadButton(DPAD_UP);
         case DPAD_DOWN:
            this.getFromFlixelGamepadButton(DPAD_DOWN);
         case DPAD_LEFT:
            this.getFromFlixelGamepadButton(DPAD_LEFT);
         case DPAD_RIGHT:
            this.getFromFlixelGamepadButton(DPAD_RIGHT);
         case LEFT_TRIGGER:
            this.getFromFlixelGamepadButton(LEFT_TRIGGER);
         case RIGHT_TRIGGER:
            this.getFromFlixelGamepadButton(RIGHT_TRIGGER);
         case LEFT_BUMPER:
            this.getFromFlixelGamepadButton(LEFT_SHOULDER);
         case RIGHT_BUMPER:
            this.getFromFlixelGamepadButton(RIGHT_SHOULDER);
         case LEFT_STICK_CLICK:
            this.getFromFlixelGamepadButton(LEFT_STICK_CLICK);
         case RIGHT_STICK_CLICK:
            this.getFromFlixelGamepadButton(RIGHT_STICK_CLICK);
         case PLUS:
            this.getFromFlixelGamepadButton(START);
         case MINUS:
            this.getFromFlixelGamepadButton(BACK);
         case HOME:
            this.getFromFlixelGamepadButton(GUIDE);
         case CAPTURE:
            this.getFromFlixelGamepadButton(EXTRA_0);
         default:
            NOT_PRESSED;
      }
   }

   override public function getConfirm():INPUT_STATE {
      return this.profile.getActionState(MENU_CONFIRM, this);
   }

   override public function getCancel():INPUT_STATE {
      return this.profile.getActionState(MENU_CANCEL, this);
   }

   override public function getMenuAction():INPUT_STATE {
      return this.profile.getActionState(MENU_ACTION, this);
   }

   override public function getMenuLeft():INPUT_STATE {
      return this.profile.getActionState(MENU_LEFT, this);
   }

   override public function getMenuRight():INPUT_STATE {
      return this.profile.getActionState(MENU_RIGHT, this);
   }

   override public function getMenuButton():INPUT_STATE {
      return this.profile.getActionState(MENU_BUTTON, this);
   }

   override public function getAttack():INPUT_STATE {
      return this.profile.getActionState(ATTACK, this);
   }

   override public function getJump():INPUT_STATE {
      return this.profile.getActionState(JUMP, this);
   }

   override public function getSpecial():INPUT_STATE {
      return this.profile.getActionState(SPECIAL, this);
   }

   override public function getStrong():INPUT_STATE {
      return this.profile.getActionState(STRONG, this);
   }

   override public function getShield():INPUT_STATE {
      return this.profile.getActionState(SHIELD, this);
   }

   override public function getWalk():INPUT_STATE {
      return this.profile.getActionState(WALK, this);
      // return NOT_PRESSED; // unused on controller
   }

   override public function getTaunt():INPUT_STATE {
      return this.profile.getActionState(TAUNT, this);
   }

   override public function getQuit():INPUT_STATE {
      return this.profile.getActionState(NULL, this);
   }

   override public function getPause():INPUT_STATE {
      return this.profile.getActionState(NULL, this);
   }

   override public function getUp():Float {
      return -Math.min(this._flixelGamepad.getYAxis(LEFT_ANALOG_STICK) * 2, 0);
   }

   override public function getDown():Float {
      return Math.max(this._flixelGamepad.getYAxis(LEFT_ANALOG_STICK) * 2, 0);
   }

   override public function getLeft():Float {
      return -Math.min(this._flixelGamepad.getXAxis(LEFT_ANALOG_STICK) * 2, 0);
   }

   override public function getRight():Float {
      return Math.max(this._flixelGamepad.getXAxis(LEFT_ANALOG_STICK) * 2, 0);
   }

   override public function getStick():StickValue {
      // TODO : make this check the control scheme first!
      var x:Float = 0;
      var y:Float = 0;

      x += this.getRight();
      x -= this.getLeft();
      y += this.getDown();
      y -= this.getUp();

      return {x: x, y: y};
   }

   override public function getCursorStick():StickValue {
      var stick = this.getStick();

      stick.x -= InputHelper.asInt(getButtonState(DPAD_LEFT));
      stick.x += InputHelper.asInt(getButtonState(DPAD_RIGHT));
      stick.y -= InputHelper.asInt(getButtonState(DPAD_UP));
      stick.y += InputHelper.asInt(getButtonState(DPAD_DOWN));

      if (Math.sqrt((stick.x * stick.x) + (stick.y * stick.y)) > 1) {
         var len = Math.sqrt((stick.x * stick.x) + (stick.y * stick.y));
         stick.x /= len;
         stick.y /= len;
      }

      return stick;
   }

   override public function getDirection():StickValue {
      return {x: 0, y: 0};
   }

   override public function getRawDirection():StickValue {
      return {x: 0, y: 0};
   }
}
