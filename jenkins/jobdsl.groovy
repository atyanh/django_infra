pipelineJob('ci_cd_pipeline') {
    triggers {
              scm('H/20 * * * *')
    }
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        github('atyanh/django_infra')
                    }
                }
            }
            scriptPath('jenkins/pipeline.groovy')
        }
    }
    properties {
        githubProjectUrl('https://github.com/atyanh/django')
    }
}