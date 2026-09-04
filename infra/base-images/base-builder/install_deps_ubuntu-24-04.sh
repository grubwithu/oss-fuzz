#!/bin/bash -eux
# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

# Install base-builder's dependencies in a architecture-aware way.


case $(uname -m) in
    x86_64)
	dpkg --add-architecture i386
        ;;
esac

# Orchestra: fail hard instead of silently skipping the package install.
# The previous `apt-get update && apt-get install ...` form skipped the whole
# install when update failed (e.g. proxy 502) yet the layer still exited 0,
# poisoning the build cache with an image that has no curl/wget.
apt-get update || exit 1

apt-get install -y \
        binutils-dev \
        build-essential \
        curl \
        wget \
        git \
        jq \
        patchelf \
        rsync \
        subversion \
        zip || exit 1

case $(uname -m) in
    x86_64)
	apt-get install -y libc6-dev-i386 || exit 1
        ;;
esac

# Ubuntu 24.04 does not have lcab. Install an older .deb from Ubuntu repos.
curl -LO https://mirrors.edge.kernel.org/ubuntu/pool/universe/l/lcab/lcab_1.0b12-7_amd64.deb || exit 1
apt-get install -y ./lcab_1.0b12-7_amd64.deb || exit 1
rm lcab_1.0b12-7_amd64.deb

# Create a custom apt configuration to allow downgrades and non-interactive installs.
cat <<EOF > /etc/apt/apt.conf.d/99-oss-fuzz-apt-defaults
// OSS-Fuzz custom apt configuration.
// Automatically allow downgrades and assume "yes" to all prompts.
APT::Get::Allow-Downgrades "true";
APT::Get::Assume-Yes "true";
EOF
