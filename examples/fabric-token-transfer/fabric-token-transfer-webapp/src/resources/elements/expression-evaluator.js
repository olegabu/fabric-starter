import {inject} from 'aurelia-dependency-injection';
import {ViewResources} from 'aurelia-templating';
import {
  createOverrideContext,
  Parser,
  Expression,
  Binary,
  CallMember,
  Conditional,
  LiteralPrimitive,
  LiteralString
} from 'aurelia-binding';
import {BindingLanguage} from 'aurelia-templating';


@inject(Parser, BindingLanguage)
export class InterpolationParser {
  emptyStringExpression = new LiteralString('');
  nullExpression = new LiteralPrimitive(null);
  undefinedExpression = new LiteralPrimitive(undefined);
  cache = {};

  constructor(parser, bindingLanguage) {
    this.parser = parser;
    this.bindingLanguage = bindingLanguage;
  }

  parse(expressionText) {
    if (this.cache[expressionText] !== undefined) {
      return this.cache[expressionText];
    }

    const parts = this.bindingLanguage.parseInterpolation(null, expressionText);
    if (parts === null) {
      return new LiteralString(expressionText);
    }
    let expression = new LiteralString(parts[0]);
    for (let i = 1; i < parts.length; i += 2) {
      expression = new Binary(
        '+',
        expression,
        new Binary(
          '+',
          this.coalesce(parts[i]),
          new LiteralString(parts[i + 1])
        )
      );
    }

    this.cache[expressionText] = expression;

    return expression;
  }

  coalesce(part) {
    // part === null || part === undefined ? '' : part
    return new Conditional(
      new Binary(
        '||',
        new Binary('===', part, this.nullExpression),
        new Binary('===', part, this.undefinedExpression)
      ),
      this.emptyStringExpression,
      new CallMember(part, 'toString', [])
    );
  }
}

@inject(Parser, InterpolationParser, ViewResources)
export class ExpressionEvaluator {
  constructor(parser, interpolationParser, resources) {
    this.parser = parser;
    this.interpolationParser = interpolationParser;
    this.lookupFunctions = resources.lookupFunctions;
  }

  evaluate(expressionText, bindingContext) {
    const expression = this.parser.parse(expressionText);
    return this.evaluateInternal(expression, bindingContext);
  }

  evaluateInterpolation(expressionText, bindingContext) {
    const expression = this.interpolationParser.parse(expressionText);
    return this.evaluateInternal(expression, bindingContext);
  }

  evaluateInternal(expression, bindingContext) {
    const scope = {
      bindingContext,
      overrideContext: createOverrideContext(bindingContext)
    };
    return expression.evaluate(scope, this.lookupFunctions);
  }
}
