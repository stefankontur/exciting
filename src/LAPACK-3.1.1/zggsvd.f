      SUBROUTINE ZGGSVD( JOBU, JOBV, JOBQ, M, N, P, K, L, A, LDA, B,
     $                   LDB, ALPHA, BETA, U, LDU, V, LDV, Q, LDQ, WORK,
     $                   RWORK, IWORK, INFO )
*
*  -- LAPACK driver routine (version 3.1) --
*     Univ. of Tennessee, Univ. of California Berkeley and NAG Ltd..
*     November 2006
*
*     .. Scalar Arguments ..
      CHARACTER          JOBQ, JOBU, JOBV
      INTEGER            INFO, K, L, LDA, LDB, LDQ, LDU, LDV, M, N, P
*     ..
*     .. Array Arguments ..
      INTEGER            IWORK( * )
      DOUBLE PRECISION   ALPHA( * ), BETA( * ), RWORK( * )
      COMPLEX*16         A( LDA, * ), B( LDB, * ), Q( LDQ, * ),
     $                   U( LDU, * ), V( LDV, * ), WORK( * )
*     ..
*
*  Purpose
*  =======
*
*  ZGGSVD computes the generalized singular value decomposition (GSVD)
*  of an M-by-N complex matrix A and P-by-N complex matrix B:
*
*        U'*A*Q = D1*( 0 R ),    V'*B*Q = D2*( 0 R )
*
*  where U, V and Q are unitary matrices, and Z' means the conjugate
*  transpose of Z.  Let K+L = the effective numerical rank of the
*  matrix (A',B')', then R is a (K+L)-by-(K+L) nonsingular upper
*  triangular matrix, D1 and D2 are M-by-(K+L) and P-by-(K+L) "diagonal"
*  matrices and of the following structures, respectively:
*
*  If M-K-L >= 0,
*
*                      K  L
*         D1 =     K ( I  0 )
*                  L ( 0  C )
*              M-K-L ( 0  0 )
*
*                    K  L
*         D2 =   L ( 0  S )
*              P-L ( 0  0 )
*
*                  N-K-L  K    L
*    ( 0 R ) = K (  0   R11  R12 )
*              L (  0    0   R22 )
*  where
*
*    C = diag( ALPHA(K+1), ... , ALPHA(K+L) ),
*    S = diag( BETA(K+1),  ... , BETA(K+L) ),
*    C**2 + S**2 = I.
*
*    R is stored in A(1:K+L,N-K-L+1:N) on exit.
*
*  If M-K-L < 0,
*
*                    K M-K K+L-M
*         D1 =   K ( I  0    0   )
*              M-K ( 0  C    0   )
*
*                      K M-K K+L-M
*         D2 =   M-K ( 0  S    0  )
*              K+L-M ( 0  0    I  )
*                P-L ( 0  0    0  )
*
*                     N-K-L  K   M-K  K+L-M
*    ( 0 R ) =     K ( 0    R11  R12  R13  )
*                M-K ( 0     0   R22  R23  )
*              K+L-M ( 0     0    0   R33  )
*
*  where
*
*    C = diag( ALPHA(K+1), ... , ALPHA(M) ),
*    S = diag( BETA(K+1),  ... , BETA(M) ),
*    C**2 + S**2 = I.
*
*    (R11 R12 R13 ) is stored in A(1:M, N-K-L+1:N), and R33 is stored
*    ( 0  R22 R23 )
*    in B(M-K+1:L,N+M-K-L+1:N) on exit.
*
*  The routine computes C, S, R, and optionally the unitary
*  transformation matrices U, V and Q.
*
*  In particular, if B is an N-by-N nonsingular matrix, then the GSVD of
*  A and B implicitly gives the SVD of A*inv(B):
*                       A*inv(B) = U*(D1*inv(D2))*V'.
*  If ( A',B')' has orthnormal columns, then the GSVD of A and B is also
*  equal to the CS decomposition of A and B. Furthermore, the GSVD can
*  be used to derive the solution of the eigenvalue problem:
*                       A'*A x = lambda* B'*B x.
*  In some literature, the GSVD of A and B is presented in the form
*                   U'*A*X = ( 0 D1 ),   V'*B*X = ( 0 D2 )
*  where U and V are orthogonal and X is nonsingular, and D1 and D2 are
*  ``diagonal''.  The former GSVD form can be converted to the latter
*  form by taking the nonsingular matrix X as
*
*                        X = Q*(  I   0    )
*                              (  0 inv(R) )
*
*  Arguments
*  =========
*
*  JOBU    (input) CHARACTER*1
*          = 'U':  Unitary matrix U is computed;
*          = 'N':  U is not computed.
*
*  JOBV    (input) CHARACTER*1
*          = 'V':  Unitary matrix V is computed;
*          = 'N':  V is not computed.
*
*  JOBQ    (input) CHARACTER*1
*          = 'Q':  Unitary matrix Q is computed;
*          = 'N':  Q is not computed.
*
*  M       (input) INTEGER
*          The number of rows of the matrix A.  M >= 0.
*
*  N       (input) INTEGER
*          The number of columns of the matrices A and B.  N >= 0.
*
*  P       (input) INTEGER
*          The number of rows of the matrix B.  P >= 0.
*
*  K       (output) INTEGER
*  L       (output) INTEGER
*          On exit, K and L specify the dimension of the subblocks
*          described in Purpose.
*          K + L = effective numerical rank of (A',B')'.
*
*  A       (input/output) COMPLEX*16 array, dimension (LDA,N)
*          On entry, the M-by-N matrix A.
*          On exit, A contains the triangular matrix R, or part of R.
*          See Purpose for details.
*
*  LDA     (input) INTEGER
*          The leading dimension of the array A. LDA >= max(1,M).
*
*  B       (input/output) COMPLEX*16 array, dimension (LDB,N)
*          On entry, the P-by-N matrix B.
*          On exit, B contains part of the triangular matrix R if
*          M-K-L < 0.  See Purpose for details.
*
*  LDB     (input) INTEGER
*          The leading dimension of the array B. LDB >= max(1,P).
*
*  ALPHA   (output) DOUBLE PRECISION array, dimension (N)
*  BETA    (output) DOUBLE PRECISION array, dimension (N)
*          On exit, ALPHA and BETA contain the generalized singular
*          value pairs of A and B;
*            ALPHA(1:K) = 1,
*            BETA(1:K)  = 0,
*          and if M-K-L >= 0,
*            ALPHA(K+1:K+L) = C,
*            BETA(K+1:K+L)  = S,
*          or if M-K-L < 0,
*            ALPHA(K+1:M)= C, ALPHA(M+1:K+L)= 0
*            BETA(K+1:M) = S, BETA(M+1:K+L) = 1
*          and
*            ALPHA(K+L+1:N) = 0
*            BETA(K+L+1:N)  = 0
*
*  U       (output) COMPLEX*16 array, dimension (LDU,M)
*          If JOBU = 'U', U contains the M-by-M unitary matrix U.
*          If JOBU = 'N', U is not referenced.
*
*  LDU     (input) INTEGER
*          The leading dimension of the array U. LDU >= max(1,M) if
*          JOBU = 'U'; LDU >= 1 otherwise.
*
*  V       (output) COMPLEX*16 array, dimension (LDV,P)
*          If JOBV = 'V', V contains the P-by-P unitary matrix V.
*          If JOBV = 'N', V is not referenced.
*
*  LDV     (input) INTEGER
*          The leading dimension of the array V. LDV >= max(1,P) if
*          JOBV = 'V'; LDV >= 1 otherwise.
*
*  Q       (output) COMPLEX*16 array, dimension (LDQ,N)
*          If JOBQ = 'Q', Q contains the N-by-N unitary matrix Q.
*          If JOBQ = 'N', Q is not referenced.
*
*  LDQ     (input) INTEGER
*          The leading dimension of the array Q. LDQ >= max(1,N) if
*          JOBQ = 'Q'; LDQ >= 1 otherwise.
*
*  WORK    (workspace) COMPLEX*16 array, dimension (max(3*N,M,P)+N)
*
*  RWORK   (workspace) DOUBLE PRECISION array, dimension (2*N)
*
*  IWORK   (workspace/output) INTEGER array, dimension (N)
*          On exit, IWORK stores the sorting information. More
*          precisely, the following loop will sort ALPHA
*             for I = K+1, min(M,K+L)
*                 swap ALPHA(I) and ALPHA(IWORK(I))
*             endfor
*          such that ALPHA(1) >= ALPHA(2) >= ... >= ALPHA(N).
*
*  INFO    (output) INTEGER
*          = 0:  successful exit.
*          < 0:  if INFO = -i, the i-th argument had an illegal value.
*          > 0:  if INFO = 1, the Jacobi-type procedure failed to
*                converge.  For further details, see subroutine ZTGSJA.
*
*  Internal Parameters
*  ===================
*
*  TOLA    DOUBLE PRECISION
*  TOLB    DOUBLE PRECISION
*          TOLA and TOLB are the thresholds to determine the effective
*          rank of (A',B')'. Generally, they are set to
*                   TOLA = MAX(M,N)*norm(A)*MAZHEPS,
*                   TOLB = MAX(P,N)*norm(B)*MAZHEPS.
*          The size of TOLA and TOLB may affect the size of backward
*          errors of the decomposition.
*
*  Further Details
*  ===============
*
*  2-96 Based on modifications by
*     Ming Gu and Huan Ren, Computer Science Division, University of
*     California at Berkeley, USA
*
*  =====================================================================
*
*     .. Local Scalars ..
      LOGICAL            WANTQ, WANTU, WANTV
      INTEGER            I, IBND, ISUB, J, NCYCLE
      DOUBLE PRECISION   ANORM, BNORM, SMAX, TEMP, TOLA, TOLB, ULP, UNFL
*     ..
*     .. External Functions ..
      LOGICAL            LSAME
      DOUBLE PRECISION   DLAMCH, ZLANGE
      EXTERNAL           LSAME, DLAMCH, ZLANGE
*     ..
*     .. External Subroutines ..
      EXTERNAL           DCOPY, XERBLA, ZGGSVP, ZTGSJA
*     ..
*     .. Intrinsic Functions ..
      INTRINSIC          MAX, MIN
*     ..
*     .. Executable Statements ..
*
*     Decode and test the input parameters
*
      WANTU = LSAME( JOBU, 'U' )
      WANTV = LSAME( JOBV, 'V' )
      WANTQ = LSAME( JOBQ, 'Q' )
*
      INFO = 0
      IF( .NOT.( WANTU .OR. LSAME( JOBU, 'N' ) ) ) THEN
         INFO = -1
      ELSE IF( .NOT.( WANTV .OR. LSAME( JOBV, 'N' ) ) ) THEN
         INFO = -2
      ELSE IF( .NOT.( WANTQ .OR. LSAME( JOBQ, 'N' ) ) ) THEN
         INFO = -3
      ELSE IF( M.LT.0 ) THEN
         INFO = -4
      ELSE IF( N.LT.0 ) THEN
         INFO = -5
      ELSE IF( P.LT.0 ) THEN
         INFO = -6
      ELSE IF( LDA.LT.MAX( 1, M ) ) THEN
         INFO = -10
      ELSE IF( LDB.LT.MAX( 1, P ) ) THEN
         INFO = -12
      ELSE IF( LDU.LT.1 .OR. ( WANTU .AND. LDU.LT.M ) ) THEN
         INFO = -16
      ELSE IF( LDV.LT.1 .OR. ( WANTV .AND. LDV.LT.P ) ) THEN
         INFO = -18
      ELSE IF( LDQ.LT.1 .OR. ( WANTQ .AND. LDQ.LT.N ) ) THEN
         INFO = -20
      END IF
      IF( INFO.NE.0 ) THEN
         CALL XERBLA( 'ZGGSVD', -INFO )
         RETURN
      END IF
*
*     Compute the Frobenius norm of matrices A and B
*
      ANORM = ZLANGE( '1', M, N, A, LDA, RWORK )
      BNORM = ZLANGE( '1', P, N, B, LDB, RWORK )
*
*     Get machine precision and set up threshold for determining
*     the effective numerical rank of the matrices A and B.
*
      ULP = DLAMCH( 'Precision' )
      UNFL = DLAMCH( 'Safe Minimum' )
      TOLA = MAX( M, N )*MAX( ANORM, UNFL )*ULP
      TOLB = MAX( P, N )*MAX( BNORM, UNFL )*ULP
*
      CALL ZGGSVP( JOBU, JOBV, JOBQ, M, P, N, A, LDA, B, LDB, TOLA,
     $             TOLB, K, L, U, LDU, V, LDV, Q, LDQ, IWORK, RWORK,
     $             WORK, WORK( N+1 ), INFO )
*
*     Compute the GSVD of two upper "triangular" matrices
*
      CALL ZTGSJA( JOBU, JOBV, JOBQ, M, P, N, K, L, A, LDA, B, LDB,
     $             TOLA, TOLB, ALPHA, BETA, U, LDU, V, LDV, Q, LDQ,
     $             WORK, NCYCLE, INFO )
*
*     Sort the singular values and store the pivot indices in IWORK
*     Copy ALPHA to RWORK, then sort ALPHA in RWORK
*
      CALL DCOPY( N, ALPHA, 1, RWORK, 1 )
      IBND = MIN( L, M-K )
      DO 20 I = 1, IBND
*
*        Scan for largest ALPHA(K+I)
*
         ISUB = I
         SMAX = RWORK( K+I )
         DO 10 J = I + 1, IBND
            TEMP = RWORK( K+J )
            IF( TEMP.GT.SMAX ) THEN
               ISUB = J
               SMAX = TEMP
            END IF
   10    CONTINUE
         IF( ISUB.NE.I ) THEN
            RWORK( K+ISUB ) = RWORK( K+I )
            RWORK( K+I ) = SMAX
            IWORK( K+I ) = K + ISUB
         ELSE
            IWORK( K+I ) = K + I
         END IF
   20 CONTINUE
*
      RETURN
*
*     End of ZGGSVD
*
      END