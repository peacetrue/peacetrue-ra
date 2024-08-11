# see https://blog.logrocket.com/how-to-build-component-library-react-typescript/
# 硬链接复用：ln -f $workingDir/learn-make/react-lib.mk react-lib.mk

# make -f "$workingDir/learn-make/react-lib.mk" create/
create/%:
	mkdir -p $*
	ln -f $$workingDir/learn-make/react-lib.mk $*/react-lib.mk

.gitignore:
	printf "$$gitignore" > "$@"
define gitignore
# See https://help.github.com/articles/ignoring-files/ for more about ignoring files.

# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# production
/build

# misc
.DS_Store
.env.local
.env.development.local
.env.test.local
.env.production.local

npm-debug.log*
yarn-debug.log*
yarn-error.log*

.idea
dist
*storybook.log
endef
export gitignore
git-init:
	git init

npm-init:
	npm init -y
npm-init/package.json:
	sed -i 's/xiayx/peacetrue/' package.json
	sed -i '/"version"/a\  "files": ["dist"],' package.json

npm-install-ts:
	npm i typescript tslib --save-dev
npx-tsc-init:
	npx tsc -init
tsconfig.json:
	printf "$$tsconfig" > $@
define tsconfig
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noFallthroughCasesInSwitch": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
endef
export tsconfig

npm-install-react:
	npm i react
	npm i @types/react --save-dev

npm-install-jest:
	npm install @testing-library/react jest @types/jest jest-environment-jsdom --save-dev
jest/package.json:
	sed -i '/"test":/d' package.json
	sed -i '/"scripts": {/a\\t"test": "jest",' package.json
jest.config.js:
	printf "$$jest_config" > $@
define jest_config
// jest.config.js
module.exports = {
  testEnvironment: "jsdom",
  moduleNameMapper: {
    ".(css|less|scss)$$": "identity-obj-proxy",
  },
};
endef
export jest_config

npm-install-babel:
	npm install @babel/core @babel/preset-env @babel/preset-react @babel/preset-typescript babel-jest --save-dev
npm-install-identity-obj-proxy:
	npm install identity-obj-proxy -save-dev
babel.config.js:
	printf "$$babel_config" > $@
define babel_config
// babel.config.js
module.exports = {
    presets: [
      "@babel/preset-env",
      "@babel/preset-react",
      "@babel/preset-typescript",
    ],
 };
endef
export babel_config

npx-sb-init:
	npx sb init --type react --builder webpack5
#	npx sb init --type react --builder webpack5 --yes

src/components/smartrating:
	mkdir -p $@
	echo "export * from './components';" > src/index.ts
	echo "export * from './smartrating';" > '$(dir $@)index.ts'
	echo "export * from './SmartRating';" > '$@/index.ts'
	printf "$$SmartRating_types" > '$@/SmartRating.types.ts'
	printf "$$SmartRating_css" > '$@/SmartRating.css'
	printf "$$SmartRating" > '$@/SmartRating.tsx'
	printf "$$SmartRating_test" > '$@/SmartRating.test.tsx'
	printf "$$SmartRating_story" > '$@/SmartRating.stories.tsx'
define SmartRating_types
export interface SmartRatingProps {
    testIdPrefix: string;
    title?: string;
    theme: "primary" | "secondary";
    disabled?: boolean;
}
endef
export SmartRating_types
define SmartRating_css
body {
    padding: 100px;
    font-size: large;
    text-align: left;
  }

span {
    margin-left: 10px;
    background-color: transparent;
    border: none;
    outline: none;
    cursor: pointer;
    :hover {
      color: grey;
    }
  }

  .star{
    font-size: large;
  }
  .starActive {
    color: red;
  }
  .starInactive {
    color: #ccc;
  }

  .rating-secondary {
    background-color: black;
    color: white;
    padding:6px;
  }
endef
export SmartRating_css
define SmartRating
import React, { useState } from "react";
import "./SmartRating.css";
import { SmartRatingProps } from "./SmartRating.types";

export const SmartRating: React.FC<SmartRatingProps> = (props) => {
  const stars = Array.from({ length: 5 }, (_, i) => i + 1);
  const [rating, setRating] = useState(0);
  return (
    <div className={`star-rating rating-$${props.theme}`}>
      <h1>{props.title}</h1>
      {stars.map((star, index) => {
        const starCss = star <= rating ? "starActive" : "starInactive";
        return (
          <button
            disabled={props.disabled}
            data-testid={`$${props.testIdPrefix}-$${index}`}
            key={star}
            className={`$${starCss}`}
            onClick={() => setRating(star)}
          >
            <span className="star">★</span>
          </button>
        );
      })}
    </div>
  );
};
endef
export SmartRating
define SmartRating_story
// smartRating.stories.tsx
import React from "react";
import { StoryFn, Meta } from "@storybook/react";
import {SmartRating} from "./SmartRating";

export default {
  title: "ReactComponentLibrary/Rating",
  component: SmartRating,
} as Meta<typeof SmartRating>;

const Template: StoryFn<typeof SmartRating> = (args) => <SmartRating {...args} />;

export const RatingTest = Template.bind({});
RatingTest.args = {
  title: "Default theme",
  theme: "primary",
  testIdPrefix: "rating",
};

export const RatingSecondary = Template.bind({});
RatingSecondary.args = {
  title: "Secondary theme",
  theme: "secondary",
  testIdPrefix: "rating",
};
endef
export SmartRating_story
define SmartRating_test
import React from "react";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import {SmartRating} from "./SmartRating";

describe("SmartRating", () => {
  test("renders the Rating component", () => {
    render(<SmartRating title="default" theme="primary" testIdPrefix="rating" />);

    expect(screen.getByRole("heading").innerHTML).toEqual("default");
    expect(screen.getAllByRole("button", { hidden: true }).length).toEqual(5);
  });

  test("click the 5 star rating", async () => {
    const stars = [0, 1, 2, 3, 4];
    render(<SmartRating title="default" theme="primary" testIdPrefix="rating" />);

    stars.forEach(async (star) => {
      const element = screen.getByTestId("rating-" + star);
      userEvent.click(element);
      await waitFor(() => expect(element.className).toBe("starActive"));
    });
  });
});
endef
export SmartRating_test

npm-install-rollup:
	npm install rollup @rollup/plugin-node-resolve @rollup/plugin-commonjs @rollup/plugin-typescript rollup-plugin-peer-deps-external @rollup/plugin-terser rollup-plugin-dts --save-dev
rollup/package.json:
	sed -i '/"main":/d' package.json
	sed -i '/"scripts": {/i\  "main": "dist/cjs/index.js",' package.json
	sed -i '/"scripts": {/i\  "module": "dist/esm/index.js",' package.json
	sed -i '/"scripts": {/i\  "types": "dist/index.d.ts",' package.json
	sed -i '/"scripts": {/a\    "build": "rollup -c --bundleConfigAsCjs",' package.json
rollup.config.js:
	printf "$$rollup_config" > $@
define rollup_config
// rollup.config.js
import resolve from "@rollup/plugin-node-resolve";
import commonjs from "@rollup/plugin-commonjs";
import typescript from "@rollup/plugin-typescript";
import dts from "rollup-plugin-dts";
import terser from "@rollup/plugin-terser";
import peerDepsExternal from "rollup-plugin-peer-deps-external";

const packageJson = require("./package.json");

export default [
  {
    input: "src/index.ts",
    output: [
      {
        file: packageJson.main,
        format: "cjs",
        sourcemap: true,
      },
      {
        file: packageJson.module,
        format: "esm",
        sourcemap: true,
      },
    ],
    plugins: [
      peerDepsExternal(),
      resolve(),
      commonjs(),
      typescript({ tsconfig: "./tsconfig.json" }),
      terser(),
    ],
    external: ["react", "react-dom"],
  },
  {
    input: "src/index.ts",
    output: [{ file: "dist/types.d.ts", format: "es" }],
    plugins: [dts.default()],
  },
];
endef
export rollup_config

npm-install-rollup-plugin-postcss:
	npm install rollup-plugin-postcss --save-dev
css/rollup.config.js:
	sed -i '/import peerDepsExternal/a\import postcss from "rollup-plugin-postcss";' rollup.config.js
	sed -i '/terser()/a\\t\t\tpostcss(),' rollup.config.js
	sed -i '/dts.default/a\\t\texternal: [/\.css$$/],' rollup.config.js

npm-install-rollup-plugin-visualizer:
	npm install --save-dev rollup-plugin-visualizer
visualizer/rollup.config.js:
	sed -i '/import peerDepsExternal/a\import { visualizer } from "rollup-plugin-visualizer";' rollup.config.js
	sed -i '/terser()/a\\t\t\tvisualizer({filename: "stats.html",template: "treemap",}),' rollup.config.js

npm-view:
	npm view $(notdir $(shell pwd))
