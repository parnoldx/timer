project('com.github.parnold-x.timer', ['vala', 'c'],
    version: '0.1.0'
)

gnome = import('gnome')

asresources = gnome.compile_resources(
    'as-resources', 'data/res.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

conf = configuration_data()
# Get the package data directory under Meson
pkgdatadir = join_paths([ get_option('prefix'),
                          get_option('datadir'),
                          meson.project_name() ])

conf.set_quoted('PKGDATADIR', pkgdatadir)

# Other configs
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
add_global_arguments('-DDATADIR="' + get_option('datadir') + '"', language: 'c')
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')
cc = meson.get_compiler('c')

# Arguments for C
c_args = [
  '-include', 'config.h',
  '-w',
]


executable(
    'com.github.parnold-x.timer',
    'src/Application.vala',
    'src/ColorManager.vala',
    'src/MainWindow.vala',
    'src/TimerEntry.vala',
    'src/TitleLabel.vala',
    'src/logic/TimeSpan.vala',
    'src/logic/TimerManager.vala',
    'src/logic/TimerObject.vala',
    asresources,
    c_args: c_args,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('gio-unix-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        dependency('gstreamer-audio-1.0'),
        dependency('unity'),
        # math dependency so glib math shit works
        cc.find_library('m', required: false)
    ],
    install : true
)

meson.add_install_script('meson/post_install.py')

subdir('data')
#subdir('po')
