FROM centos:7

# Add base dependencies, and update
RUN yum -y -q update && \
		yum -y -q install which curl jq git openssl bind-utils && \
    yum -y -q clean all

# Add gcloud utilities to modify DNS records
ENV CLOUDSDK_INSTALL_DIR /usr/lib64/google-cloud-sdk
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
COPY gcloud.repo /etc/yum.repos.d/

RUN yum -y install kubectl google-cloud-sdk && \
    yum -y -q clean all
RUN mkdir -p /etc/gcloud/keys

# Disable google cloud auto update...
RUN	gcloud config set --installation component_manager/disable_update_check true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set core/disable_usage_reporting true

# Because local gcloud configs might point to opt
RUN mkdir -p /opt/google-cloud-sdk/bin && ln -s /usr/bin/gcloud /opt/google-cloud-sdk/bin/gcloud

# Get dehydrated
RUN cd /usr/local/bin && \
		git clone https://github.com/lukas2511/dehydrated && \
		cd dehydrated && \
		mkdir hooks
#		git checkout da3428a84a48d9e2db6b3107a1db0d0e8095fa0a

# Add Dehdrated to the path
ENV PATH=/usr/local/bin/dehydrated:$PATH

# Our container start point
CMD ["/app/issue.sh"]

WORKDIR /app

# Add our custom hooks
COPY hooks/ /usr/local/bin/dehydrated/hooks/

# Add our scripts
COPY scripts/* /app/

# Add configs
COPY configs/* /app/
