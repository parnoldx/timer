project('com.github.parnold-x.timer', 'vala', 'c', version: '0.3.0')

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

asresources = gnome.compile_resources(
    'as-resources',
    join_paths('data', meson.project_name()) + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

subdir('src')

executable(
    meson.project_name(),
    sources,
    asresources,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('gio-unix-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        dependency('gstreamer-audio-1.0'),
        dependency('unity'),
        meson.get_compiler('c').find_library('m', required: false)
    ],
    install : true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
