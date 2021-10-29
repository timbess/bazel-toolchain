# Copyright 2018 The Bazel Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@bazel_tools//tools/build_defs/repo:utils.bzl", "read_netrc", "use_netrc")
load("//toolchain/internal:common.bzl", _python = "python")

# If a new LLVM version is missing from this list, please add the shasum here
# and send a PR on github. To compute the shasum block, you can use the script
# utils/llvm_checksums.sh
_llvm_distributions = {
    # 6.0.0
    "clang+llvm-6.0.0-aarch64-linux-gnu.tar.xz": "69382758842f29e1f84a41208ae2fd0fae05b5eb7f5531cdab97f29dda3c2334",
    "clang+llvm-6.0.0-amd64-unknown-freebsd-10.tar.xz": "fee8352f5dee2e38fa2bb80ab0b5ef9efef578cbc6892e5c724a1187498119b7",
    "clang+llvm-6.0.0-armv7a-linux-gnueabihf.tar.xz": "4fda22e3d80994f343bfbdcae60f75e63ad44eb0998c59c559d706c11dd87b76",
    "clang+llvm-6.0.0-i386-unknown-freebsd-10.tar.xz": "13414a66b680760171e04f32071396eb6e5a179ff0b5a067d48c4b23744840f1",
    "clang+llvm-6.0.0-i686-linux-gnu-Fedora27.tar.xz": "2619e0a2542eec997daed3c7e597d99d5800cc3a07500b359429541a260d0207",
    "clang+llvm-6.0.0-mips-linux-gnu.tar.xz": "39820007ef6b2e3a4d05ec15feb477ce6e4e6e90180d00326e6ab9982ed8fe82",
    "clang+llvm-6.0.0-mipsel-linux-gnu.tar.xz": "5ff062f4838ac51a3500383faeb0731440f1c4473bf892258314a49cbaa66e61",
    "clang+llvm-6.0.0-x86_64-apple-darwin.tar.xz": "0ef8e99e9c9b262a53ab8f2821e2391d041615dd3f3ff36fdf5370916b0f4268",
    "clang+llvm-6.0.0-x86_64-linux-gnu-Fedora27.tar.xz": "2aada1f1a973d5d4d99a30700c4b81436dea1a2dcba8dd965acf3318d3ea29bb",
    "clang+llvm-6.0.0-x86_64-linux-gnu-debian8.tar.xz": "ff55cd0bdd0b67e22d1feee2e4c84dedc3bb053401330b64c7f6ac18e88a71f1",
    "clang+llvm-6.0.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz": "114e78b2f6db61aaee314c572e07b0d635f653adc5d31bd1cd0bf31a3db4a6e5",
    "clang+llvm-6.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz": "cc99fda45b4c740f35d0a367985a2bf55491065a501e2dd5d1ad3f97dcac89da",
    "clang+llvm-6.0.0-x86_64-linux-sles11.3.tar.xz": "1d4d30ebe4a7e5579644235b46513a1855d3ece865f7cc5ccd0ac5113c461ee7",
    "clang+llvm-6.0.0-x86_64-linux-sles12.2.tar.xz": "c144e17aab8dce8e8823a7a891067e27fd0686a49d8a3785cb64b0e51f08e2ee",

    # 6.0.1
    "clang+llvm-6.0.1-amd64-unknown-freebsd10.tar.xz": "6d1f67c9e7c3481106d5c9bfcb8a75e3876eb17a446a14c59c13cafd000c21d2",
    "clang+llvm-6.0.1-i386-unknown-freebsd10.tar.xz": "c6f65f2c42fa02e3b7e508664ded9b7a91ebafefae368dfa84b3d68811bcb924",
    "clang+llvm-6.0.1-x86_64-linux-gnu-ubuntu-14.04.tar.xz": "fa5416553ca94a8c071a27134c094a5fb736fe1bd0ecc5ef2d9bc02754e1bef0",
    "clang+llvm-6.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz": "7ea204ecd78c39154d72dfc0d4a79f7cce1b2264da2551bb2eef10e266d54d91",
    "clang+llvm-6.0.1-x86_64-linux-sles11.3.tar.xz": "d128e2a7ea8b42418ec58a249e886ec2c736cbbbb08b9e11f64eb281b62bc574",
    "clang+llvm-6.0.1-x86_64-linux-sles12.3.tar.xz": "79c74f4764d13671285412d55da95df42b4b87064785cde3363f806dbb54232d",

    # 7.0.0
    "clang+llvm-7.0.0-amd64-unknown-freebsd-10.tar.xz": "95ceb933ccf76e3ddaa536f41ab82c442bbac07cdea6f9fbf6e3b13cc1711255",
    "clang+llvm-7.0.0-i386-unknown-freebsd-10.tar.xz": "35460d34a8b3d856e0d7c0b2b20d31f0d1ec05908c830a81f586721e8f8fb04f",
    "clang+llvm-7.0.0-x86_64-apple-darwin.tar.xz": "b3ad93c3d69dfd528df9c5bb1a434367babb8f3baea47fbb99bf49f1b03c94ca",
    "clang+llvm-7.0.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz": "5c90e61b06d37270bc26edb305d7e498e2c7be22d99e0afd9f2274ef5458575a",
    "clang+llvm-7.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz": "69b85c833cd28ea04ce34002464f10a6ad9656dd2bba0f7133536a9927c660d2",
    "clang+llvm-7.0.0-x86_64-linux-sles11.3.tar.xz": "1a0a94a5cef357b885d02cf46b66109b6233f0af8f02be3da08e2daf646b5cf8",
    "clang+llvm-7.0.0-x86_64-linux-sles12.3.tar.xz": "1c303f1a7b90f0f1988387dfab16f1eadbe2b2152d86a323502068379941dd17",

    # 8.0.0
    "clang+llvm-8.0.0-aarch64-linux-gnu.tar.xz": "998e9ae6e89bd3f029ed031ad9355c8b43441302c0e17603cf1de8ee9939e5c9",
    "clang+llvm-8.0.0-amd64-unknown-freebsd11.tar.xz": "af15d14bd25e469e35ed7c43cb7e035bc1b2aa7b55d26ad597a43e72768750a8",
    "clang+llvm-8.0.0-armv7a-linux-gnueabihf.tar.xz": "ddcdc9df5c33b77740e4c27486905c44ecc3c4ec178094febeab60124deb0cc2",
    "clang+llvm-8.0.0-i386-unknown-freebsd11.tar.xz": "1ba88663ccda4e9fad93f8f35dde7ce04854abc0bcbb1d12a90cdc863e4a77b8",
    "clang+llvm-8.0.0-x86_64-apple-darwin.tar.xz": "94ebeb70f17b6384e052c47fef24a6d70d3d949ab27b6c83d4ab7b298278ad6f",
    "clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz": "9ef854b71949f825362a119bf2597f744836cb571131ae6b721cd102ffea8cd0",
    "clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz": "87b88d620284d1f0573923e6f7cc89edccf11d19ebaec1cfb83b4f09ac5db09c",
    "clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz": "0f5c314f375ebd5c35b8c1d5e5b161d9efaeff0523bac287f8b4e5b751272f51",
    "clang+llvm-8.0.0-x86_64-linux-sles11.3.tar.xz": "7e2846ff60c181d1f27d97c23c25a2295f5730b6d88612ddd53b4cbb8177c4b9",

    # 8.0.1
    "clang+llvm-8.0.1-aarch64-linux-gnu.tar.xz": "3ca16b5f9e490d6c60712476c51db9d864e7d7f22904c91ad30ba8faee1ede64",
    "clang+llvm-8.0.1-amd64-unknown-freebsd11.tar.xz": "4ae625169fa0ae56cf534cddc6f8eda76123f89adac0de439d0e47885fccc813",
    "clang+llvm-8.0.1-armv7a-linux-gnueabihf.tar.xz": "c87b57496f8ec0f0fd74faa1c43b0ac12c156aae54d9be45169fd8f2b33b2181",
    "clang+llvm-8.0.1-i386-unknown-freebsd11.tar.xz": "f0ab06cce95f9339af3e27e728913414a7b775a5bdb6c90e2a4f67f8cf2a917e",
    "clang+llvm-8.0.1-powerpc64le-linux-rhel-7.4.tar.xz": "c26676326892119b015286efcd6f485b11c1055717454f6884c4ac5896ad5771",
    "clang+llvm-8.0.1-powerpc64le-linux-ubuntu-16.04.tar.xz": "7a8a422b360ad649f24e077eeee7098dd1496a82bee81792898f78ced2fe4a17",
    "clang+llvm-8.0.1-x86_64-linux-gnu-ubuntu-14.04.tar.xz": "0eb70c888c5a67f61e62ae502f4c935e3116e79e5cb3371a3be260f345fe1f16",
    "clang+llvm-8.0.1-x86_64-linux-sles11.3.tar.xz": "ec5d7fd082137ce5b72c7b4dde9a83c07a7e298773351ab6a0693a8200d0fa0c",

    # 9.0.0
    "clang+llvm-9.0.0-x86_64-pc-linux-gnu.tar.xz": "616c5f75418c88a72613b6d0a93178028f81357777226869ea6b34c23d08a12d",
    "clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz": "5c1473c2611e1eac4ed1aeea5544eac5e9d266f40c5623bbaeb1c6555815a27d",
    "clang+llvm-9.0.0-amd64-pc-solaris2.11.tar.xz": "86235763496b8174bca8fd1fcec2c99a3a29f8784814acef5c66634f86f81b16",
    "clang+llvm-9.0.0-powerpc64le-linux-ubuntu-16.04.tar.xz": "a8e7dc00e9eac47ea769eb1f5145e1e28f0610289f07f3275021f0556c169ddf",
    "clang+llvm-9.0.0-x86_64-linux-sles11.3.tar.xz": "c80b5b10df191465df8cee8c273d9c46715e6f27f80fef118ad4ebb7d9f3a7d3",
    "clang+llvm-9.0.0-amd64-unknown-freebsd11.tar.xz": "2a1f123a9d992c9719ef7677e127182ca707a5984a929f1c3f34fbb95ffbf6f3",
    "clang+llvm-9.0.0-powerpc64le-linux-rhel-7.4.tar.xz": "28052539e8e8ad204ee06910a143d992c67fef98662f83fa6f242f65ff29b386",
    "clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz": "bea706c8f6992497d08488f44e77b8f0f87f5b275295b974aa8b194efba18cb8",
    "clang+llvm-9.0.0-aarch64-linux-gnu.tar.xz": "f8f3e6bdd640079a140a7ada4eb6f5f05aeae125cf54b94d44f733b0e8691dc2",
    "clang+llvm-9.0.0-sparcv9-sun-solaris2.11.tar.xz": "7711e4cff908cad47ccab1d2e95bf3c8eb915585999c4e59bb42b10c3c502cfe",
    "clang+llvm-9.0.0-armv7a-linux-gnueabihf.tar.xz": "ff6046bf98dbc85d7cb0c3c70456bc002b99a809bfc115657db2683ba61752ec",
    "clang+llvm-9.0.0-i386-unknown-freebsd11.tar.xz": "2d8d0b712946d6bc76317c4093ce77634ef6d502c343e1f3f6b841401db8fa56",
    "clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz": "a23b082b30c128c9831dbdd96edad26b43f56624d0ad0ea9edec506f5385038d",
    "clang+llvm-9.0.0-x86_64-darwin-apple.tar.xz": "b46e3fe3829d4eb30ad72993bf28c76b1e1f7e38509fbd44192a2ef7c0126fc7",

    # 10.0.0
    "clang+llvm-10.0.0-amd64-pc-solaris2.11.tar.xz": "aaf6865542bd772e30be3abf620340a050ed5e4297f8be347e959e5483d9f159",
    "clang+llvm-10.0.0-powerpc64le-linux-ubuntu-16.04.tar.xz": "2d6298720d6aae7fcada4e909f0949d63e94fd0370d20b8882cdd91ceae7511c",
    "clang+llvm-10.0.0-x86_64-linux-sles11.3.tar.xz": "a7a3c2a7aff813bb10932636a6f1612e308256a5e6b5a5655068d5c5b7f80e86",
    "clang+llvm-10.0.0-amd64-unknown-freebsd11.tar.xz": "56d58da545743d5f2947234d413632fd2b840e38f2bed7369f6e65531af36a52",
    "clang+llvm-10.0.0-powerpc64le-linux-rhel-7.4.tar.xz": "958b8a774eae0bb25515d7fb2f13f5ead1450f768ffdcff18b29739613b3c457",
    "clang+llvm-10.0.0-aarch64-linux-gnu.tar.xz": "c2072390dc6c8b4cc67737f487ef384148253a6a97b38030e012c4d7214b7295",
    "clang+llvm-10.0.0-sparcv9-sun-solaris2.11.tar.xz": "725c9205550cabb6d8e0d8b1029176113615809dcc880b347c1577aecdf2af4c",
    "clang+llvm-10.0.0-armv7a-linux-gnueabihf.tar.xz": "ad136e0d8ce9ac1a341a54513dfd313a7a64c49afa7a69d51cdc2118f7fdc350",
    "clang+llvm-10.0.0-i386-unknown-freebsd11.tar.xz": "310ed47e957c226b0de17130711505366c225edbed65299ac2c3d59f9a59a41a",
    "clang+llvm-10.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz": "b25f592a0c00686f03e3b7db68ca6dc87418f681f4ead4df4745a01d9be63843",
    "clang+llvm-10.0.0-x86_64-apple-darwin.tar.xz": "633a833396bf2276094c126b072d52b59aca6249e7ce8eae14c728016edb5e61",

    # 10.0.1
    "clang+llvm-10.0.1-aarch64-linux-gnu.tar.xz": "90dc69a4758ca15cd0ffa45d07fbf5bf4309d47d2c7745a9f0735ecffde9c31f",
    "clang+llvm-10.0.1-amd64-unknown-freebsd11.tar.xz": "290897c328f75df041d1abda6e25a50c2e6a0a3d939b5069661bb966bf7ac843",
    "clang+llvm-10.0.1-armv7a-linux-gnueabihf.tar.xz": "adf90157520cd5e0931b9f186bed0f0463feda56370de4eba51766946f57b02b",
    "clang+llvm-10.0.1-i386-unknown-freebsd11.tar.xz": "f404976ad92cf846b7915cd43cd251e090a5e7524809ab96f5a65216988b2b26",
    "clang+llvm-10.0.1-powerpc64le-linux-rhel-7.4.tar.xz": "27359cae558905bf190834db11bbeaea433777a360744e9f79bfe69226a19117",
    "clang+llvm-10.0.1-powerpc64le-linux-ubuntu-16.04.tar.xz": "c19edf5c1f5270ae9124a3873e689a3309a9ad075373a75c0791abf4bf72602e",
    "clang+llvm-10.0.1-x86_64-apple-darwin.tar.xz": "1154a24597ab77801980dfd5ae4a13c117d6b482bab015baa410aeba443ffd92",
    "clang+llvm-10.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz": "48b83ef827ac2c213d5b64f5ad7ed082c8bcb712b46644e0dc5045c6f462c231",
    "clang+llvm-10.0.1-x86_64-linux-sles12.4.tar.xz": "59f35fc7967b740315edf31a54b228ae5da8a54f499e37d424d67b7107217ae4",

    # 11.0.0
    "clang+llvm-11.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz": "abfe77fa4c2ceda16455fac9dba58962af9173c5aa85d5bb8ca4f5165ef87a19",
    "clang+llvm-11.0.0-x86_64-linux-sles12.4.tar.xz": "ce3e2e9788e0136f3082eb3199c6e2dd171f4e7c98310f83fc284c5ba734d27a",
    "clang+llvm-11.0.0-sparcv9-sun-solaris2.11.tar.xz": "3f2bbbbd9aac9809bcc561d73b0db39ecd64fa099fac601f929da5e95a63bdc5",
    "clang+llvm-11.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz": "829f5fb0ebda1d8716464394f97d5475d465ddc7bea2879c0601316b611ff6db",
    "clang+llvm-11.0.0-amd64-pc-solaris2.11.tar.xz": "031699337d703fe42843a8326f94079fd67e46b60f25be5bdf47664e158e0b43",
    "clang+llvm-11.0.0-x86_64-apple-darwin.tar.xz": "b93886ab0025cbbdbb08b46e5e403a462b0ce034811c929e96ed66c2b07fe63a",

    # 11.0.1
    "clang+llvm-11.0.1-aarch64-linux-gnu.tar.xz": "39b3d3e3b534e327d90c77045058e5fc924b1a81d349eac2be6fb80f4a0e40d4",
    "clang+llvm-11.0.1-amd64-unknown-freebsd11.tar.xz": "cd0a6da1825bc7440c5a8dfa22add4ee91953c45aa0e5597ba1a5caf347f807d",
    "clang+llvm-11.0.1-amd64-unknown-freebsd12.tar.xz": "2daa205f87d2b81a281f3883c2102cd69ac017193b19ea30f914b57f904c7c4b",
    "clang+llvm-11.0.1-armv7a-linux-gnueabihf.tar.xz": "5c6b3a1104ac3999c11e18b42c7feca47e0bb894d55b938aba32b1c362402a52",
    "clang+llvm-11.0.1-i386-unknown-freebsd11.tar.xz": "e32ad587e800145a7868449b1416e25d05a6ca08c071ecc8173cf9e1b0b7dcdd",
    "clang+llvm-11.0.1-i386-unknown-freebsd12.tar.xz": "46e88ce3a5efef198cade0cf29ee152f3361ca4488fd7701cc79485c06aa93b8",
    "clang+llvm-11.0.1-powerpc64le-linux-rhel-7.4.tar.xz": "d270ded2cbcb76588bbf71dad2e3657961896bfadf7ff4da57d07870da537873",
    "clang+llvm-11.0.1-powerpc64le-linux-ubuntu-18.04.tar.xz": "a60a35f6c9f280268df8afe76f4a5349426f8b8eefd40eb885eae80b6e3647d0",
    "clang+llvm-11.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz": "67f18660231d7dd09dc93502f712613247b7b4395e6f48c11226629b250b53c5",
    "clang+llvm-11.0.1-x86_64-linux-gnu-ubuntu-20.10.tar.xz": "b60f68581182ace5f7d4a72e5cce61c01adc88050acb72b2070ad298c25071bc",
    "clang+llvm-11.0.1-x86_64-linux-sles12.4.tar.xz": "77cd59cf6f932cf2b3c9a68789d1bd3f7ba9f471a28f6ba25e25deb1a0806e0d",

    # 11.1.0
    "clang+llvm-11.1.0-aarch64-linux-gnu.tar.xz": "18df38247af3fba0e0e2991fb00d7e3cf3560b4d3509233a14af699ef0039e1c",
    "clang+llvm-11.1.0-amd64-unknown-freebsd11.tar.xz": "645e24018aa2694d8ccb44139f44a0d3af97fa8eab785faecb7a228ebe76ac7e",
    "clang+llvm-11.1.0-amd64-unknown-freebsd12.tar.xz": "430284b75248ab2dd3ebb8718d8bbb19cc8b9b62f4707ae47a61827b3ba59836",
    "clang+llvm-11.1.0-armv7a-linux-gnueabihf.tar.xz": "18a3c3aedf1181aa18da3f5d0a2c67366c6d5fb398ac00e461298d9584be5c68",
    "clang+llvm-11.1.0-i386-unknown-freebsd11.tar.xz": "ddc451c1094d0c8912160912d7c20d28087782758e0a8d145f301a18ddcea558",
    "clang+llvm-11.1.0-i386-unknown-freebsd12.tar.xz": "3c23d3b97f869382b33878d8a5210056c60d5e749acfeea0354682bb013f5a20",
    "clang+llvm-11.1.0-powerpc64le-linux-rhel-7.4.tar.xz": "8ff13bb70f1eb8efe61b1899e4d05d6f15c18a14a9ffa883f54f243b060fa778",
    "clang+llvm-11.1.0-powerpc64le-linux-ubuntu-18.04.tar.xz": "2741183e4ea5fccc86ec2d9ce226edcf00da90b07731b04540edb5025cc695c1",
    "clang+llvm-11.1.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz": "c691a558967fb7709fb81e0ed80d1f775f4502810236aa968b4406526b43bee1",
    "clang+llvm-11.1.0-x86_64-linux-gnu-ubuntu-20.10.tar.xz": "29b07422da4bcea271a88f302e5f84bd34380af137df18e33251b42dd20c26d7",

    # 12.0.0
    "clang+llvm-12.0.0-armv7a-linux-gnueabihf.tar.xz": "697d432c2572e48fc04118fc7cec63c9477ef2e8a7cca2c0b32e52f9705ab1cc",
    "clang+llvm-12.0.0-i386-unknown-freebsd11.tar.xz": "8298a026f74165bf6088c1c942c22bd7532b12cd2b916f7673bdaf522abe41b0",
    "clang+llvm-12.0.0-x86_64-apple-darwin.tar.xz": "7bc2259bf75c003f644882460fc8e844ddb23b27236fe43a2787870a4cd8ab50",
    "clang+llvm-12.0.0-amd64-unknown-freebsd11.tar.xz": "8ff2ae0863d4cbe88ace6cbcce64a1a6c9a8f1237f635125a5d580b2639bba61",
    "clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz": "9694f4df031c614dbe59b8431f94c68631971ad44173eecc1ea1a9e8ee27b2a3",
    "clang+llvm-12.0.0-aarch64-linux-gnu.tar.xz": "d05f0b04fb248ce1e7a61fcd2087e6be8bc4b06b2cc348792f383abf414dec48",
    "clang+llvm-12.0.0-amd64-unknown-freebsd12.tar.xz": "0a90d2cf8a3d71d7d4a6bee3e085405ebc37a854311bce82d6845d93b19fcc87",
    "clang+llvm-12.0.0-x86_64-linux-sles12.4.tar.xz": "00c25261e303080c2e8d55413a73c60913cdb39cfd47587d6817a86fe52565e9",
    "clang+llvm-12.0.0-i386-unknown-freebsd12.tar.xz": "1e61921735fd11754df193826306f0352c99ca6013e22f40a7fc77f0b20162be",
    "clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz": "a9ff205eb0b73ca7c86afc6432eed1c2d49133bd0d49e47b15be59bbf0dd292e",

    # 12.0.1
    "clang+llvm-12.0.1-amd64-unknown-freebsd11.tar.xz": "94dfe48d9e483283edbee968056d487a850b30de25258fa48f049cca3ede5db4",
    "clang+llvm-12.0.1-amd64-unknown-freebsd12.tar.xz": "38857da36489880b0504ae7142b74abe41cf18711a6bb25ca96792d8190e8b0e",
    "clang+llvm-12.0.1-i386-unknown-freebsd11.tar.xz": "346e14e5a9189838704f096e65579c8e1915f95dcc291aa7f20626ccf9767e04",
    "clang+llvm-12.0.1-i386-unknown-freebsd12.tar.xz": "1f3b5e99e82165bf3442120ee3cb2c95ca96129cf45c85a52ec8973f8904529d",
    "clang+llvm-12.0.1-armv7a-linux-gnueabihf.tar.xz": "1ec685b5026f9cc5e7316a5ff2dffd8ff54ad9941e642df19062cc1359842c86",
    "clang+llvm-12.0.1-aarch64-linux-gnu.tar.xz": "3d4ad804b7c85007686548cbc917ab067bf17eaedeab43d9eb83d3a683d8e9d4",
    "clang+llvm-12.0.1-powerpc64le-linux-rhel-7.9.tar.xz": "9849fa17fb7eb666744f1e2ce8dcb5d28753c4c482cc6f5e3d2b5ad2108dc2de",
    "clang+llvm-12.0.1-powerpc64le-linux-ubuntu-18.04.tar.xz": "271b9605b74d904d3cc05dd6a61e927fd5a46d5f6b7541cdc67186eb02b22e4c",
    "clang+llvm-12.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz": "6b3cc55d3ef413be79785c4dc02828ab3bd6b887872b143e3091692fc6acefe7",

    # 13.0.0
    "clang+llvm-13.0.0-amd64-unknown-freebsd12.tar.xz": "e579747a36ff78aa0a5533fe43bc1ed1f8ed449c9bfec43c358d953ffbbdcf76",
    "clang+llvm-13.0.0-amd64-unknown-freebsd13.tar.xz": "c4f15e156afaa530eb47ba13c46800275102af535ed48e395aed4c1decc1eaa1",
    "clang+llvm-13.0.0-i386-unknown-freebsd12.tar.xz": "4d14b19c082438a5ceed61e538e5a0298018b1773e8ba2e990f3fbe33492f48f",
    "clang+llvm-13.0.0-i386-unknown-freebsd13.tar.xz": "f8e105c6ac2fd517ae5ed8ef9b9bab4b015fe89a06c90c3dd5d5c7933dca2276",
    "clang+llvm-13.0.0-powerpc64le-linux-rhel-7.9.tar.xz": "cfade83f6da572a8ab0e4796d1f657967b342e98202c26e76c857879fb2fa2d2",
    "clang+llvm-13.0.0-powerpc64le-linux-ubuntu-18.04.tar.xz": "5d79e9e2919866a91431589355f6d07f35d439458ff12cb8f36093fb314a7028",
    "clang+llvm-13.0.0-x86_64-apple-darwin.tar.xz": "d051234eca1db1f5e4bc08c64937c879c7098900f7a0370f3ceb7544816a8b09",
    "clang+llvm-13.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz": "76d0bf002ede7a893f69d9ad2c4e101d15a8f4186fbfe24e74856c8449acd7c1",
    "clang+llvm-13.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz": "2c2fb857af97f41a5032e9ecadf7f78d3eff389a5cd3c9ec620d24f134ceb3c8",
}

# Note: Unlike the user-specified llvm_mirror attribute, the URL prefixes in
# this map are not immediately appended with "/". This is because LLVM prebuilt
# URLs changed when they switched to hosting the files on GitHub as of 10.0.0.
_llvm_distributions_base_url = {
    "6.0.0": "https://releases.llvm.org/",
    "6.0.1": "https://releases.llvm.org/",
    "7.0.0": "https://releases.llvm.org/",
    "8.0.0": "https://releases.llvm.org/",
    "8.0.1": "https://releases.llvm.org/",
    "9.0.0": "https://releases.llvm.org/",
    "10.0.0": "https://github.com/llvm/llvm-project/releases/download/llvmorg-",
    "10.0.1": "https://github.com/llvm/llvm-project/releases/download/llvmorg-",
    "11.0.0": "https://github.com/llvm/llvm-project/releases/download/llvmorg-",
    "11.0.1": "https://github.com/llvm/llvm-project/releases/download/llvmorg-",
    "11.1.0": "https://github.com/llvm/llvm-project/releases/download/llvmorg-",
    "12.0.0": "https://github.com/llvm/llvm-project/releases/download/llvmorg-",
    "12.0.1": "https://github.com/llvm/llvm-project/releases/download/llvmorg-",
    "13.0.0": "https://github.com/llvm/llvm-project/releases/download/llvmorg-",
}

def _get_auth(ctx, urls):
    """
    Given the list of URLs obtain the correct auth dict.

    Based on:
    https://github.com/bazelbuild/bazel/blob/793964e8e4268629d82fabbd08bf1a7718afa301/tools/build_defs/repo/http.bzl#L42
    """
    netrcpath = None
    if ctx.attr.netrc:
        netrcpath = ctx.attr.netrc
    elif not ctx.os.name.startswith("windows"):
        if "HOME" in ctx.os.environ:
            netrcpath = "%s/.netrc" % (ctx.os.environ["HOME"])
    elif "USERPROFILE" in ctx.os.environ:
        netrcpath = "%s/.netrc" % (ctx.os.environ["USERPROFILE"])

    if netrcpath and ctx.path(netrcpath).exists:
        netrc = read_netrc(ctx, netrcpath)
        return use_netrc(netrc, urls, ctx.attr.auth_patterns)

    return {}

def download_llvm_preconfigured(rctx):
    llvm_version = rctx.attr.llvm_version

    if rctx.attr.distribution == "auto":
        exec_result = rctx.execute([
            _python(rctx),
            rctx.path(rctx.attr._llvm_release_name),
            llvm_version,
        ])
        if exec_result.return_code:
            fail("Failed to detect host OS version: \n%s\n%s" % (exec_result.stdout, exec_result.stderr))
        if exec_result.stderr:
            print(exec_result.stderr)
        basename = exec_result.stdout.strip()
    else:
        basename = rctx.attr.distribution

    if basename not in _llvm_distributions:
        fail("Unknown LLVM release: %s\nPlease ensure file name is correct." % basename)

    urls = []
    url_suffix = "{0}/{1}".format(llvm_version, basename).replace("+", "%2B")
    if rctx.attr.llvm_mirror:
        urls.append("{0}/{1}".format(rctx.attr.llvm_mirror, url_suffix))
    if rctx.attr.alternative_llvm_sources:
        for pattern in rctx.attr.alternative_llvm_sources:
            urls.append(pattern.format(llvm_version = llvm_version, basename = basename))
    urls.append("{0}{1}".format(_llvm_distributions_base_url[llvm_version], url_suffix))

    rctx.download_and_extract(
        urls,
        sha256 = _llvm_distributions[basename],
        stripPrefix = basename[:(len(basename) - len(".tar.xz"))],
        auth = _get_auth(rctx, urls),
    )
