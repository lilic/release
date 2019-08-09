{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'build-cop-target-low',
        rules: [
          {
            alert: '%s-low' % job_name_regex,
            expr: |||
              sum(rate(prowjob_state_transitions{job="plank",job_name=~"%s",job_name!~"rehearse.*",state="success"}[30m]))/sum(rate(prowjob_state_transitions{job="plank",job_name=~"%s",job_name!~"rehearse.*",state=~"success|failure"}[30m])) * 100 < 100
            ||| % [job_name_regex, job_name_regex],
            'for': '30m',
            labels: {
              severity: 'slack',
              team: 'build-cop',
            },
            annotations: {
              message: '@build-cop `%s` jobs are passing at a rate of {{ $value | humanize }}%%, which is below the target (100%%). Check the <https://grafana-prow-monitoring.svc.ci.openshift.org/d/%s/build-cop-dashboard?orgId=1&fullscreen&panelId=2|dashboard> and <https://prow.svc.ci.openshift.org/?job=%s|deck-portal>.' % [job_name_regex, $._config.grafanaDashboardIDs['build_cop.json'], std.strReplace(job_name_regex, '.*', '*')],
            },
          }
          for job_name_regex in ['branch-.*-images', 'release-.*-4.1', 'release-.*-4.2', 'release-.*-upgrade.*']
        ],
      },
      {
        name: 'ipi-deprovision',
        rules: [
          {
            alert: 'ipi-deprovision-failures',
            expr: |||
              rate(prowjob_state_transitions{job_name="periodic-ipi-deprovision",state="failure"}[30m]) > 0
            |||,
            'for': '1m',
            labels: {
              severity: 'slack',
            },
            annotations: {
              message: 'ipi-deprovision has failures. Check on <https://grafana-prow-monitoring.svc.ci.openshift.org/d/6829209d59479d48073d09725ce807fa/build-cop-dashboard?orgId=1&fullscreen&panelId=9|grafana>',
            },
          }
        ],
      },
    ],
  },
}
