*
*     ---------------------------------------------------------------
*        T I N V I T
*     ---------------------------------------------------------------
*
*
      SUBROUTINE TINVIT(NM,N,D,E,E2,M,W,IND,Z,
     :                  IERR,RV1,RV2,RV3,RV4,RV6)
*
      INTEGER I,J,M,N,P,Q,R,S,II,IP,JJ,NM,ITS,TAG,IERR,GROUP
      DOUBLE PRECISION D(N),E(N),E2(N),W(M),Z(NM,M),
     :       RV1(N),RV2(N),RV3(N),RV4(N),RV6(N)
      DOUBLE PRECISION U,V,UK,XU,X0,X1,EPS2,EPS3,EPS4,NORM,ORDER,MACHEP
      DOUBLE PRECISION DSQRT,DABS,DFLOAT
      INTEGER IND(M)
*
*     THIS SUBROUTINE IS A TRANSLATION OF THE INVERSE ITERATION TECH-
*     NIQUE IN THE ALGOL PROCEDURE TRISTURM BY PETERS AND WILKINSON.
*     HANDBOOK FOR AUTO. COMP., VOL.II-LINEAR ALGEBRA, 418-439(1971).
*
*     THIS SUBROUTINE FINDS THOSE EIGENVECTORS OF A TRIDIAGONAL
*     SYMMETRIC MATRIX CORRESPONDING TO SPECIFIED EIGENVALUES,
*     USING INVERSE ITERATION.
*
*     ON INPUT:
*
*        NM MUST BE SET TO THE ROW DIMENSION OF TWO-DIMENSIONAL
*          ARRAY PARAMETERS AS DECLARED IN THE CALLING PROGRAM
*          DIMENSION STATEMENT;
*
*        N IS THE ORDER OF THE MATRIX;
*
*        D CONTAINS THE DIAGONAL ELEMENTS OF THE INPUT MATRIX;
*
*        E CONTAINS THE SUBDIAGONAL ELEMENTS OF THE INPUT MATRIX
*          IN ITS LAST N-1 POSITIONS.  E(1) IS ARBITRARY;
*
*        E2 CONTAINS THE SQUARES OF THE CORRESPONDING ELEMENTS OF E,
*          WITH ZEROS CORRESPONDING TO NEGLIGIBLE ELEMENTS OF E.
*          E(I) IS CONSIDERED NEGLIGIBLE IF IT IS NOT LARGER THAN
*          THE PRODUCT OF THE RELATIVE MACHINE PRECISION AND THE SUM
*          OF THE MAGNITUDES OF D(I) AND D(I-1).  E2(1) MUST CONTAIN
*          0.0D0 IF THE EIGENVALUES ARE IN ASCENDING ORDER, OR 2.0D0
*          IF THE EIGENVALUES ARE IN DESCENDING ORDER.  IF  BISECT,
*          TRIDIB, OR  IMTQLV  HAS BEEN USED TO FIND THE EIGENVALUES,
*          THEIR OUTPUT E2 ARRAY IS EXACTLY WHAT IS EXPECTED HERE;
*
*        M IS THE NUMBER OF SPECIFIED EIGENVALUES;
*
*        W CONTAINS THE M EIGENVALUES IN ASCENDING OR DESCENDING ORDER;
*
*        IND CONTAINS IN ITS FIRST M POSITIONS THE SUBMATRIX INDICES
*          ASSOCIATED WITH THE CORRESPONDING EIGENVALUES IN W --
*          1 FOR EIGENVALUES BELONGING TO THE FIRST SUBMATRIX FROM
*          THE TOP, 2 FOR THOSE BELONGING TO THE SECOND SUBMATRIX, ETC.
*
*     ON OUTPUT:
*
*        ALL INPUT ARRAYS ARE UNALTERED;
*
*        Z CONTAINS THE ASSOCIATED SET OF ORTHONORMAL EIGENVECTORS.
*          ANY VECTOR WHICH FAILS TO CONVERGE IS SET TO ZERO;
*
*        IERR IS SET TO
*          ZERO       FOR NORMAL RETURN,
*          -R         IF THE EIGENVECTOR CORRESPONDING TO THE R-TH
*                     EIGENVALUE FAILS TO CONVERGE IN 5 ITERATIONS;
*
*        RV1, RV2, RV3, RV4, AND RV6 ARE TEMPORARY STORAGE ARRAYS.
*
*     QUESTIONS AND COMMENTS SHOULD BE DIRECTED TO B. S. GARBOW,
*     APPLIED MATHEMATICS DIVISION, ARGONNE NATIONAL LABORATORY
*
*     ------------------------------------------------------------------
*
*     :::::::::: MACHEP IS A MACHINE DEPENDENT PARAMETER SPECIFYING
*                THE RELATIVE PRECISION OF FLOATING POINT ARITHMETIC.
*                MACHEP = 16.0D0**(-13) FOR LONG FORM ARITHMETIC
*                ON S360 ::::::::::
      DATA MACHEP/1.D-12/
*
      IERR = 0
      IF (M .EQ. 0) GO TO 1001
      TAG = 0
      ORDER = 1.0D0 - E2(1)
      Q = 0
*     :::::::::: ESTABLISH AND PROCESS NEXT SUBMATRIX ::::::::::
  100 P = Q + 1
*
      DO 120 Q = P, N
         IF (Q .EQ. N) GO TO 140
         IF (E2(Q+1) .EQ. 0.0D0) GO TO 140
  120 CONTINUE
*     :::::::::: FIND VECTORS BY INVERSE ITERATION ::::::::::
  140 TAG = TAG + 1
      S = 0
*
      DO 920 R = 1, M
         IF (IND(R) .NE. TAG) GO TO 920
         ITS = 1
         X1 = W(R)
         IF (S .NE. 0) GO TO 510
*     :::::::::: CHECK FOR ISOLATED ROOT ::::::::::
         XU = 1.0D0
         IF (P .NE. Q) GO TO 490
         RV6(P) = 1.0D0
         GO TO 870
  490    NORM = DABS(D(P))
         IP = P + 1
*
         DO 500 I = IP, Q
  500    NORM = NORM + DABS(D(I)) + DABS(E(I))
*     :::::::::: EPS2 IS THE CRITERION FOR GROUPING,
*                EPS3 REPLACES ZERO PIVOTS AND EQUAL
*                ROOTS ARE MODIFIED BY EPS3,
*                EPS4 IS TAKEN VERY SMALL TO AVOID OVERFLOW ::::::::::
         EPS2 = 1.0D-3 * NORM
         EPS3 = MACHEP * NORM
         UK = DFLOAT(Q-P+1)
         EPS4 = UK * EPS3
         UK = EPS4 / DSQRT(UK)
         S = P
  505    GROUP = 0
         GO TO 520
*     :::::::::: LOOK FOR CLOSE OR COINCIDENT ROOTS ::::::::::
  510    IF (DABS(X1-X0) .GE. EPS2) GO TO 505
         GROUP = GROUP + 1
         IF (ORDER * (X1 - X0) .LE. 0.0D0) X1 = X0 + ORDER * EPS3
*     :::::::::: ELIMINATION WITH INTERCHANGES AND
*                INITIALIZATION OF VECTOR ::::::::::
  520    V = 0.0D0
*
         DO 580 I = P, Q
            RV6(I) = UK
            IF (I .EQ. P) GO TO 560
            IF (DABS(E(I)) .LT. DABS(U)) GO TO 540
*     :::::::::: WARNING -- A DIVIDE CHECK MAY OCCUR HERE IF
*                E2 ARRAY HAS NOT BEEN SPECIFIED CORRECTLY ::::::::::
            XU = U / E(I)
            RV4(I) = XU
            RV1(I-1) = E(I)
            RV2(I-1) = D(I) - X1
            RV3(I-1) = 0.0D0
            IF (I .NE. Q) RV3(I-1) = E(I+1)
            U = V - XU * RV2(I-1)
            V = -XU * RV3(I-1)
            GO TO 580
  540       XU = E(I) / U
            RV4(I) = XU
            RV1(I-1) = U
            RV2(I-1) = V
            RV3(I-1) = 0.0D0
  560       U = D(I) - X1 - XU * V
            IF (I .NE. Q) V = E(I+1)
  580    CONTINUE
*
         IF (U .EQ. 0.0D0) U = EPS3
         RV1(Q) = U
         RV2(Q) = 0.0D0
         RV3(Q) = 0.0D0
*     :::::::::: BACK SUBSTITUTION
*                FOR I=Q STEP -1 UNTIL P DO -- ::::::::::
  600    DO 620 II = P, Q
            I = P + Q - II
            RV6(I) = (RV6(I) - U * RV2(I) - V * RV3(I)) / RV1(I)
            V = U
            U = RV6(I)
  620    CONTINUE
*     :::::::::: ORTHOGONALIZE WITH RESPECT TO PREVIOUS
*                MEMBERS OF GROUP ::::::::::
         IF (GROUP .EQ. 0) GO TO 700
         J = R
*
         DO 680 JJ = 1, GROUP
  630       J = J - 1
            IF (IND(J) .NE. TAG) GO TO 630
            XU = 0.0D0
*
            DO 640 I = P, Q
  640       XU = XU + RV6(I) * Z(I,J)
*
            DO 660 I = P, Q
  660       RV6(I) = RV6(I) - XU * Z(I,J)
*
  680    CONTINUE
*
  700    NORM = 0.0D0
*
         DO 720 I = P, Q
  720    NORM = NORM + DABS(RV6(I))
*
         IF (NORM .GE. 1.0D0) GO TO 840
*     :::::::::: FORWARD SUBSTITUTION ::::::::::
         IF (ITS .EQ. 5) GO TO 830
         IF (NORM .NE. 0.0D0) GO TO 740
         RV6(S) = EPS4
         S = S + 1
         IF (S .GT. Q) S = P
         GO TO 780
  740    XU = EPS4 / NORM
*
         DO 760 I = P, Q
  760    RV6(I) = RV6(I) * XU
*     :::::::::: ELIMINATION OPERATIONS ON NEXT VECTOR
*                ITERATE ::::::::::
  780    DO 820 I = IP, Q
            U = RV6(I)
*     :::::::::: IF RV1(I-1) .EQ. E(I), A ROW INTERCHANGE
*                WAS PERFORMED EARLIER IN THE
*                TRIANGULARIZATION PROCESS ::::::::::
            IF (RV1(I-1) .NE. E(I)) GO TO 800
            U = RV6(I-1)
            RV6(I-1) = RV6(I)
  800       RV6(I) = U - RV4(I) * RV6(I-1)
  820    CONTINUE
*
         ITS = ITS + 1
         GO TO 600
*     :::::::::: SET ERROR -- NON-CONVERGED EIGENVECTOR ::::::::::
  830    IERR = -R
         XU = 0.0D0
         GO TO 870
*     :::::::::: NORMALIZE SO THAT SUM OF SQUARES IS
*                1 AND EXPAND TO FULL ORDER ::::::::::
  840    U = 0.0D0
*
         DO 860 I = P, Q
  860    U = U + RV6(I)**2
*
         XU = 1.0D0 / DSQRT(U)
*
  870    DO 880 I = 1, N
  880    Z(I,R) = 0.0D0
*
         DO 900 I = P, Q
  900    Z(I,R) = RV6(I) * XU
*
         X0 = X1
  920 CONTINUE
*
      IF (Q .LT. N) GO TO 100
 1001 RETURN
*     :::::::::: LAST CARD OF TINVIT ::::::::::
      END
