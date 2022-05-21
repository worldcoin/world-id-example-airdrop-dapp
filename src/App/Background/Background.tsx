import backgroundMobilePng from "dist/background-mobile.png";
import backgroundPng from "dist/bg5.png";
import React from "react";

export const Background = React.memo(function Background() {
  return (
    <div className="pointer-events-none fixed inset-0 h-full w-full">
      <img
        src={backgroundPng}
        alt=""
        className="fixed hidden h-full w-full object-cover object-center xs:block"
      />
      <img
        src={backgroundMobilePng}
        alt=""
        className="fixed block h-full w-full object-cover object-bottom xs:hidden"
      />
    </div>
  );
});
