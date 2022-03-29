package scripting;

/**
   the compiler takes a root node that contains sub nodes and compiles it into a list of actions that can be executed
**/
class ScriptCompiler {
   static var actions:Array<ScriptAction>;

   static inline function add(a:ScriptAction):Void {
      actions.push(a);
   }

   static function expr(node:ScriptNode):Void {
      switch (node) {
         case NNumber(p, f):
            add(ANumber(p, f));
         case NIdentifier(p, s):
            add(AIdentifier(p, s));
         case NUnOperator(p, op, q):
            expr(q);
            add(AUnOperation(p, op));
         case NOperator(p, op, a, b):
            expr(a);
            expr(b);
            add(AOperation(p, op));
         case NString(p, v):
            add(AString(p, v));
         case NCall(p, name, args):
            for (arg in args) {
               expr(arg);
            }
            add(ACall(p, name, args.length));
         case NBlock(p, nodes):
            for (blockNode in nodes)
               expr(blockNode);
         case NReturn(p, ret):
            expr(ret);
            add(AReturn(p));
         case NDiscard(p, ret):
            expr(ret);
            add(ADiscard(p));
         case NConditional(p, condition, result, elseResult):
            expr(condition);
            var jump1index = actions.length;
            expr(result);
            var jump2index = 0;
            if (elseResult != null) {
               expr(elseResult);
               jump2index = actions.length;
            }
            actions.insert(jump1index, AJumpUnless(p, actions.length));
            if (elseResult != null) {
               actions.insert(jump2index - 1, AJump(p, actions.length + 1));
            }
         case NSet(p, node, value): {
            expr(value);
            switch (node) {
               case NIdentifier(p, name): {
                  add(ASet(p, node.getParameters()[1]));
               }
               default: throw 'Expression is not settable at $p';
            }
         }
      }
   }

   public static function compile(node:ScriptNode):Array<ScriptAction> {
      actions = [];
      expr(node);
      return actions;
   }
}
