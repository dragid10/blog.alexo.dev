
# blog.alexo.dev

![Vercel Deploy](https://therealsujitk-vercel-badge.vercel.app/?app=blog-alexo-dev&style=flat-square)

The code that hosts [Alex's blog](https://blog.alexo.dev)

## Tech Stack

Languages:

- **Ruby**      >= 3.1.3
  - [Bundler package manager](https://bundler.io/)
- **Node.js**   >= 20.0.0
  - [Yarn package manager](https://yarnpkg.com/)

Frameworks:

- [**Jekyll**](https://jekyllrb.com/)
- [**TinaCMS**](https://tina.io/)

Deployment:

- [**asdf**](https://asdf-vm.com/)
- [**Vercel**](https://vercel.com/)

Other Tools:

- [Gitmoji-cli](https://github.com/carloscuesta/gitmoji-cli)
- [readme.so](https://readme.so/)
- [Vercel Badge Tool](https://therealsujitk-vercel-badge.vercel.app/)

Site Theme:

- [**Minimal-Mistakes**](https://github.com/mmistakes/minimal-mistakes)

## Run Locally

1. Clone the project

    ```bash
    git clone https://github.com/dragid10/blog.alexo.dev
    ```

1. Go to the project directory

    ```bash
    cd blog.alexo.dev
    ```

1. Install asdf version manager following these instructions:

    ```plain
    https://asdf-vm.com/guide/getting-started.html#_2-download-asdf
    ```

1. Install asdf plugins

    ```bash
    # Ruby Plugin
    asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git

    # NodeJS plugin
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    ```

1. Install dependencies

    ```bash
    asdf install
    yarn install
    bundle instal
    ```

1. Start the server

    ```bash
    yarn clean && yarn dev
    ```

1. The site should now be available at: http://localhost:4000

## License

[MIT](https://choosealicense.com/licenses/mit/)
