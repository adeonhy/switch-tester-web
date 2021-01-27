[@bs.scope "document"] [@bs.val]
external addKeybordEventListener:
  (string, ReactEvent.Keyboard.t => unit) => unit =
  "addEventListener";

[@bs.scope "document"] [@bs.val]
external removeKeybordEventListener:
  (string, ReactEvent.Keyboard.t => unit) => unit =
  "removeEventListener";

type help =
  | SwitchPins
  | SwitchType;

module HelpView = {
  [@react.component]
  let make = (~helpType: option(help), ~onHide) => {
    switch (helpType) {
    | None => React.null
    | Some(h) =>
      let helpImageUrl =
        switch (h) {
        | SwitchPins => Consts.helpImageOfPins
        | SwitchType => Consts.helpImageOfSwitchTypes
        };
      <div>
        <div className="modal">
          <img src=helpImageUrl className="help-image" />
        </div>
        <div className="overlay" onClick=onHide />
      </div>;
    };
  };
};

module DefaultView = {
  [@react.component]
  let make = () => {
    <div className="center">
      <img src=Consts.urlOfTopImage className="default-image" />
    </div>;
  };
};

module HelpButton = {
  [@react.component]
  let make = (~helpType: help, ~showHelpCallback) => {
    <img
      src="public/question.svg"
      className="help-icon"
      onClick={_ => showHelpCallback(helpType)}
    />;
  };
};

module SwitchAttributesView = {
  [@react.component]
  let make = (~attributes: KeySwitch.attributeType) => {
    <dl>
      {attributes
       |> KeySwitch.arrayOfAttributes
       |> Array.map(((k, v)) => {
            [|<dt> {React.string(k)} </dt>, <dd> {React.string(v)} </dd>|]
          })
       |> Belt.Array.concatMany
       |> React.array}
    </dl>;
  };
};

module SwitchView = {
  [@react.component]
  let make =
      (~keySwitch: option(KeySwitch.t), ~stock: option(StockDescription.t)) => {
    let (helpType, setHelpType) = React.useState(_ => None);

    let stockDescription =
      stock
      ->Belt.Option.map(st => st.description)
      ->Belt.Option.getWithDefault("");

    let handleShowHelp = (helpType: help) => {
      setHelpType(_ => Some(helpType));
    };

    switch (keySwitch) {
    | None => <DefaultView />
    | Some(s) =>
      <div className="summary">
        <HelpView helpType onHide={_ => setHelpType(_ => None)} />
        <div className="summary-image">
          <img src={s.imageUrl} className="switch-image" />
        </div>
        <div className="summary-info">
          <p className="switch-comment"> {React.string(s.comment)} </p>
          <p className="switch-name"> {React.string(s.name)} </p>
          <div className="right">
            <span className="stock-description">
              {React.string(stockDescription)}
            </span>
          </div>
          <div className="right">
            <span className="small"> {React.string({j|価格 |j})} </span>
            <span className="switch-price"> {React.string(s.price)} </span>
            <span className="small"> {React.string({j| 円|j})} </span>
          </div>
          <p className="switch-type">
            {React.string(s.type_ ++ {j|軸 / |j} ++ s.weight ++ "g")}
            <HelpButton helpType=SwitchType showHelpCallback=handleShowHelp />
          </p>
          <p className="switch-type">
            {React.string({j|ピン数: |j} ++ s.pin)}
            <HelpButton helpType=SwitchPins showHelpCallback=handleShowHelp />
          </p>
        </div>
        <div className="switch-detail">
          <SwitchAttributesView attributes={s.otherAttributes} />
        </div>
      </div>
    };
  };
};

// entry point
[@react.component]
let make = () => {
  let (showDefault, setShowDefault) = React.useState(() => true);
  let (count, setCount) = React.useState(() => 0);
  let (currentKey, setCurrentKey) = React.useState(() => None);

  let keyMatcher =
    KeyMapping.useKeyMatcher(Consts.urlOfSwitchesSpreadsheetJson);
  let stockMatcher =
    StockDescription.useStockMatcher(Consts.urlOfStocksSpreadsheetJson);

  let handleKeyDown = (k: ReactEvent.Keyboard.t): unit => {
    Js.log(ReactEvent.Keyboard.key(k));
    setCount(_ => 0);
    setCurrentKey(_ => Some(k));
  };

  React.useEffect0(() => {
    let id =
      Js.Global.setInterval(
        () =>
          if (count >= Consts.claerIntervalSec) {
            setCount(_ => 0);
            setShowDefault(_ => true);
          } else {
            setCount(c => c + 1);
            setShowDefault(_ => false);
          },
        1000,
      );
    Some(() => Js.Global.clearInterval(id));
  });

  React.useEffect0(() => {
    addKeybordEventListener("keydown", handleKeyDown);
    Some(() => removeKeybordEventListener("keyDown", handleKeyDown));
  });

  let keySwitch: option(KeySwitch.t) = keyMatcher(currentKey);
  let stock: option(StockDescription.t) = stockMatcher(keySwitch);

  <div className="container">
    {showDefault ? <DefaultView /> : <SwitchView keySwitch stock />}
  </div>;
};
