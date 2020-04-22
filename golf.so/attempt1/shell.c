//
//  http://git.savannah.gnu.org/cgit/coreutils.git/tree/src/true.c
//  int
//  main (int argc, char **argv)
//  {
//    /* Recognize --help or --version only if it's the only command-line
//       argument.  */
//    if (argc == 2)
//      {
//        initialize_main (&argc, &argv);
//        set_program_name (argv[0]);
//        setlocale (LC_ALL, "");
//        bindtextdomain (PACKAGE, LOCALEDIR);
//        textdomain (PACKAGE);
//  
//        /* Note true(1) will return EXIT_FAILURE in the
//           edge case where writes fail with GNU specific options.  */
//        atexit (close_stdout);
//  
//        if (STREQ (argv[1], "--help"))
//          usage (EXIT_STATUS);
//  
//        if (STREQ (argv[1], "--version"))
//          version_etc (stdout, PROGRAM_NAME, PACKAGE_NAME, Version, AUTHORS,
//                       (char *) NULL);
//      }
//  
//    return EXIT_STATUS;
//  } 
//  build with:
//  	gcc -shared -nostdlib -nostartfiles -s -fPIC -o putter.so shell.c
//  execute:
//	LD_PRELOAD=./putter.so /bin/true
//
//
//  Best optimization gets to ~10Kb
//
//


#include <unistd.h>
#include <stdio.h>

__attribute__((__constructor__))
void shell()
{
	char * argv [] = { "/bin/sh", NULL};
	execve("/bin/sh", argv, NULL);
}
