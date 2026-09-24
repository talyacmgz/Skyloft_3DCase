using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FishinRodController : MonoBehaviour
{
    public Transform startPoint;
    public Transform endPoint;
    public LineRenderer lineRenderer;

    private void Start()
    {
        lineRenderer.SetPosition(0, startPoint.position);
        lineRenderer.SetPosition(1, endPoint.position);

    }

    private void Update()
    {
        lineRenderer.SetPosition(0, startPoint.position);
        endPoint.position = lineRenderer.GetPosition(1);

    }

}
